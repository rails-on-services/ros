# frozen_string_literal: true

module Ros
  class Devops
    attr_accessor :config

    def initialize(config)
      self.config = config
    end

    def provision
      puts "Provision platform config '#{config.name}' of type #{config.type} in #{Ros.env} environment"
      puts "Work dir: #{Ros.tf_root}/#{config.provider}/provision/#{config.type}"
      Dir.chdir("#{Ros.tf_root}/#{config.provider}/provision/#{config.type}") do
        File.open('state.tf.json', 'w') { |f| f.puts(JSON.pretty_generate(tf_state)) }
        File.open('terraform.tfvars', 'w') { |f| f.puts(JSON.pretty_generate(tf_vars)) }
        system('terraform init')
        system('terraform apply')
      end
      send("provision_#{config.type}")
    end

    def provision_instance
      puts "TODO: After terraform apply, write instance IP to devops/ansible/inventory/#{config.type}"
    end

    def provision_kubernetes; end

    def tf_state
      {
        terraform: {
          backend: {
            "#{config.tf_state.type}": config.tf_state.to_h.select {|k,v| k.to_s != 'type'} || {}
          }
        }
      }
    end

    def tf_vars; send("#{config.type}_tf_vars") end

    def kubernetes_tf_vars
      if config.provider.eql? 'aws'
        {
          aws_region: config.aws_region,
          route53_zone_main_name: config.dns.domain,
          route53_zone_this_name: config.dns.subdomain,
          name: config.name
        }
      elsif config.provider.eql? 'gcp'
      elsif config.provider.eql? 'azure'
      end
    end

    def instance_tf_vars
      if config.provider.eql? 'aws'
        {
          ec2_ami_distro: config.ami_distro,
          aws_region: config.aws_region,
          route53_zone_main_name: config.dns.domain,
          route53_zone_this_name: config.dns.subdomain,
          ec2_tags: config.ec2_tags,
          ec2_instance_type: config.instance_type,
          ec2_key_pair: config.ec2_key_pair,
          lambda_filename: config.lambda_filename
        }
      elsif config.provider.eql? 'gcp'
      elsif config.provider.eql? 'azure'
      end
    end

    def deploy_instance
      puts "Deploy platform config '#{config.name}' of type #{config.type} in #{Ros.env} environment"
      puts "Work dir: #{Ros.ansible_root}"
      Dir.chdir(Ros.ansible_root) do
        cmd = "ansible-playbook ./#{config.type}.yml"
        puts cmd
        # system(cmd)
        puts 'TODO: ansible code to invoke compose to spin up images'
      end
    end

    def deploy_kubernetes
      puts "Deploy platform config '#{config.name}' of type #{config.type} in #{Ros.env} environment"
      send("delploy_kubernetes_#{ENV['ROS_ENV']}")
    end

    def deploy_kubernetes_production
      raise NotImplementedError
      # Dir.chdir(Ros.helm_root) do
      #   cmd = 'helm apply'
      #   puts cmd
      #   # system(cmd)
      #   puts 'TODO: Apply helm charts'
      # end
    end

    def deploy_kubernetes_development
      # NOTE: terraform code generates the kubeconfig file
      abort "Kubeconfig not found at #{kubeconfig}" unless File.file?(kubeconfig)
      puts "Using kubeconfig file: #{kubeconfig}"
      prepare_cluster
      deploy_infrastructure
      set_kubernetes_secret
    end

    def prepare_cluster
      Dir.chdir(Ros.k8s_root) do
        system(shell_env, "kubectl create ns #{config.namespace} || true")
        system(shell_env, "kubectl label namespace #{config.namespace} istio-injection=enabled --overwrite")
        puts 'Initialize helm and tiller'
        system(shell_env, "kubectl apply -n #{config.namespace} -f tiller-rbac")
        system(shell_env, 'helm init --upgrade --wait --service-account tiller')
      end
    end

    def deploy_infrastructure
      # Deploy supporting infrastructure: PG, Redis, etc
      Dir.chdir("#{Ros.k8s_root}/basic-components") do
        system(shell_env, "kubectl apply -n #{config.namespace} -f manifests")
        system(shell_env, "skaffold deploy -n #{config.namespace}")
      end
      # Create ingress rules
      Dir.chdir("#{Ros.helm_root}") do
        service_names =  Ros.services.values.map{ |s| s.name }
        helm_value_services = service_names.collect.with_index{ |x, i|
          "services[#{i}].name=#{x},services[#{i}].port=80,services[#{i}].prefix=#{x}"
        }.join(',')
        cmd = "helm upgrade --install --namespace #{config.namespace} --set #{helm_value_services} " \
          "--set hosts={api.#{config.dns.subdomain}.#{config.dns.domain}} ingress ./charts/ingress"
        puts "running #{cmd}"
        system(shell_env, cmd)
      end
    end

    # Create kubernetes secret if not exist
    def set_kubernetes_secret
      return unless File.file?("#{Ros.root}/config/env")
      return if system(shell_env, "kubectl -n #{config.namespace} get secret ros-common")
      cmd = "kubectl -n #{config.namespace} create secret generic ros-common --from-env-file #{Ros.root}/config/env"
      puts "running #{cmd}"
      system(shell_env, cmd)
    end

    # Run skaffold deploy for each service
    def deploy_services
      Ros.services.collect{ |x| x[1] }.each do |service|
        next unless File.file?("#{service.root}/skaffold.yaml")
        Dir.chdir("#{service.root}") do
          cmd = "skaffold deploy -n #{config.namespace}"
          puts "Deploying #{service.name} with #{cmd}"
          system(shell_env, cmd)
        end
      end
    end

    def shell_env
      @shell_env ||= { 'KUBECONFIG' => kubeconfig, 'TILLER_NAMESPACE' => config.namespace }
    end

    def kubeconfig
      @kubeconfig ||= "#{Ros.tf_root}/#{config.provider}/provision/kubernetes/kubeconfig_#{config.name}"
    end
  end
end
