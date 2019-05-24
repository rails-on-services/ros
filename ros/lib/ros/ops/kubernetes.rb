# frozen_string_literal: true

module Ros
  module Ops
    module Kubernetes
      class Infra < Deployment
        include Ros::Ops::Kubernetes
        include Ros::Ops::Infra

        def tf_vars_aws
          {
            aws_region: infra.aws_region,
            route53_zone_main_name: infra.dns.domain,
            route53_zone_this_name: infra.dns.subdomain,
            name: infra.name
          }
        end
      end

      # provision a platform into the infrastructure, including:
      # env to secrets, support services (pg, redis, localstack, etc) and S3 bucket
      # TODO: add fluentd and grafana skaffolds
      # TODO: provision S3 bucket
      # TODO: implement rollback of support services and S3 bucket
      class Platform < Deployment
        include Ros::Ops::Kubernetes
        include Ros::Ops::Platform

        def initialize
          super
          infra.namespace ||= 'default'
          infra.branch_deployments ||= false
          infra.api_branch ||= 'master'
        end

        def template_vars(name, profile_name)
          {
            chart_path: "#{relative_path}/devops/helm/charts/#{name}",
            api_hostname: api_hostname,
            service_names: services.keys
          }
        end

        def fluentd_header
          "configMaps:\n  rails-audit-log.conf: |"
        end

        def provision
          return unless provision_check
          # Dir.chdir(deploy_root) do
            provision_namespace
            provision_helm
            provision_secrets
            provision_services
          # end
        end

        def provision_namespace
          system_cmd(kube_env, "kubectl create ns #{namespace}") unless system_cmd(kube_env, "kubectl get ns #{namespace}")
          system_cmd(kube_env, "kubectl label namespace #{namespace} istio-injection=enabled --overwrite")
        end

        def provision_helm
          kube_ctl("apply -f #{Ros.k8s_root}/tiller-rbac")
          system_cmd(kube_env, 'helm init --upgrade --wait --service-account tiller')
        end

        def provision_secrets
          Dir["#{deploy_root}/*.env"].each { |file| sync_secret(file) }
        end

        def provision_services
          # ["#{deploy_root}/ingress.yml"].each { |file| skaffold("deploy -f #{file}") }
          Dir["#{deploy_root}/*.yml"].each { |file| skaffold("deploy -f #{file}") }
        end

        def rollback; puts "TODO: rollback #{self.class.name}" end
      end

      class Service < Deployment
        include Ros::Ops::Service
        include Ros::Ops::Kubernetes

        def template_vars(name, profile_name)
          {
            name: name,
            context_path: relative_path,
            dockerfile_path: "#{relative_path}/Dockerfile",
            image: images[platform.services.image],
            chart_path: "#{relative_path}/devops/helm/charts/service",
            api_hostname: api_hostname,
            app_command: profiles.dig(profile_name, :app_command),
            bootstrap_enabled: profiles.dig(profile_name, :bootstrap_enabled),
            bootstrap_command: profiles.dig(profile_name, :bootstrap_command),
            pull_policy: 'Always',
            secrets_files: services.dig(name, :environment) ? [:platform, name.to_sym] : %i(platform)
          }
        end

        # provisions service specific infrastructure scoped to the platform:
        # TODO: process service env files, crete sns path on platform’s S3 bucket, etc
        def provision
          return unless provision_check and gem_version_check
          Dir["#{service_root}/*.env"].each { |file| sync_secret(file) }
          Dir["#{service_root}/*.yml"].each do |file|
            skaffold("build -f #{file}")
            service.profiles.each { |profile| skaffold("deploy -f #{file} -p #{profile}") }
          end
        end

        # TODO Destroy a service using skaffold and remove secrets
        def rollback; puts "rollback #{self.class.name}" end
      end

      def sync_secret(file)
        name = File.basename(file).chomp('.env')
        # TODO: base64 decode values then do an md5 on the contents
        # yaml = kube_ctl("get secret #{name} -o yaml")
        kube_ctl("delete secret #{name}") if kube_ctl("get secret #{name}")
        kube_ctl("create secret generic #{name} --from-env-file #{file}")
      end

      def provision_check
        puts File.file?(kubeconfig) ? "Using kubeconfig file: #{kubeconfig}" : "Kubeconfig not found at #{kubeconfig}"
        File.file?(kubeconfig) 
      end

      def template_prefix; 'skaffold' end

      def deploy_path; "#{Ros.env}/#{namespace}" end

      def kube_ctl(cmd); system_cmd(kube_env, "kubectl -n #{namespace} #{cmd}") end

      def kube_env; @kube_env ||= { 'KUBECONFIG' => kubeconfig, 'TILLER_NAMESPACE' => namespace } end

      def skaffold(cmd); system_cmd(skaffold_env, "skaffold -n #{namespace} #{cmd}") end

      def skaffold_env
        @skaffold_env ||=
          { 'SKAFFOLD_DEFAULT_REPO' => image.registry, 'IMAGE_TAG' => image_tag }.merge(kube_env)
      end

      def namespace
        @namespace ||=
          if infra.branch_deployments
            branch_name.eql?(infra.api_branch) ? infra.namespace : branch_name
          else
            infra.namespace
          end
      end

      def kubeconfig
        @kubeconfig ||= File.expand_path(infra.kubeconfig ||
          "#{Ros.tf_root}/#{infra.provider}/provision/kubernetes/kubeconfig_#{name}")
      end
    end
  end
end
