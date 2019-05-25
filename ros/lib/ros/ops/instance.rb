# frozen_string_literal: true
require 'ros/deployment'
require 'ros/ops/infra'
require 'ros/ops/platform'
require 'ros/ops/service'

module Ros
  module Ops
    module Instance
      class Infra < Deployment
        include Ros::Ops::Infra
        include Ros::Ops::Instance

        def tf_vars_aws
          {
            ec2_ami_distro: infra.ami_distro,
            aws_region: infra.aws_region,
            route53_zone_main_name: infra.dns.domain,
            route53_zone_this_name: infra.dns.subdomain,
            ec2_tags: infra.ec2_tags,
            ec2_instance_type: infra.instance_type,
            ec2_key_pair: infra.ec2_key_pair,
            lambda_filename: infra.lambda_filename
          }
        end

        def after_provision
          puts "TODO: After terraform apply, write instance IP to devops/ansible/inventory/#{infra.type}"
        end
      end

      class Platform < Deployment
        include Ros::Ops::Platform
        include Ros::Ops::Instance

        def template_vars(name, profile_name)
          {
            name: name,
            service_names: services.keys,
            basic_service_names: platform.basic_services.keys,
            relative_path_from_root: relative_path_from_root
          }
        end

        def write_nginx
          content = File.read("#{template_services_root}/nginx/nginx.conf.erb")
          content = ERB.new(content).result_with_hash({ service_names: services.keys })
          content_dir = "#{platform_root}/nginx"
          FileUtils.mkdir_p(content_dir)
          File.write("#{content_dir}/nginx.conf", content)
        end

        # TODO: this should probably be platform agnostic code rather than instance
        def write_sftp
          content_dir = "#{platform_root}/sftp"
          FileUtils.mkdir_p("#{content_dir}/host-config/authorized-keys")
          Dir.chdir("#{content_dir}/host-config") do
            %x(ssh-keygen -P '' -t ed25519 -f ssh_host_ed25519_key < /dev/null)
            %x(ssh-keygen -P '' -t rsa -b 4096 -f ssh_host_rsa_key < /dev/null)
          end
          Dir.chdir(content_dir) { FileUtils.touch('users.conf') }
        end

        def provision; puts "provision: Nothing to do" end
        def rollback; puts "rollback: Nothing to do" end
      end

      class Service < Deployment
        include Ros::Ops::Service
        include Ros::Ops::Instance

        def template_vars(name, profile_name)
          has_envs = !services.dig(name, :environment).nil?
          use_ros_context_dir = (not Ros.is_ros? and services.dig(name, :ros))
          mount_ros = (not Ros.is_ros? and not services.dig(name, :ros))
          {
            relative_path: relative_path,
            name: name,
            has_envs: has_envs,
            image: image,
            context_dir: use_ros_context_dir ? 'ROS_CONTEXT_DIR' : 'CONTEXT_DIR',
            mount: services.dig(name, :mount),
            mount_ros: mount_ros
          }
        end

        def after_configure
          write_compose_envs
        end

        def write_compose_envs
          content = compose_envs.each_with_object([]) do |kv, ary|
            ary << "#{kv[0].upcase}=#{kv[1]}"
          end.join("\n")
          content = "# This file was auto generated\n# The values are used by docker-compose\n# #{Ros.env}\n#{content}"
          FileUtils.mkdir_p("#{Ros.root}/config/compose")
          File.write("#{Ros.root}/config/compose/#{Ros.env}.env", content)
        end

        def compose_envs
          {
            compose_file: Dir["#{deploy_root}/**/*.yml"].map{ |p| p.gsub("#{Ros.root}/", '') }.join(':'),
            compose_project_name: platform.environment.partition_name,
            context_dir: "#{relative_path}/..",
            ros_context_dir: "#{relative_path}/../ros",
            nginx_host_port: platform.nginx_host_port,
            image_repository: Settings.devops.registry,
            image_tag: image_tag
          }
        end

        # TODO: stop and rm are passed directly to compose and exits
        # TODO: should be possible to run defaults on port 3000 and another version on 3001
        # by changing the project name in config/app
        # TODO: get working in ros and enclosing project: 'CONTEXT_DIR' => Ros.is_ros? ? '..' : '../ros'
        def provision
          FileUtils.rm('.env')
          FileUtils.ln_s("config/compose/#{Ros.env}.env", '.env')
          return unless gem_version_check
          if options.build
            services.keys.each { |service| compose("build #{service}") }
            return
          end
          compose_options = options.daemon ? '-d' : ''
          compose("up #{compose_options}")
        end

        # def provision_with_ansible
        #   puts "Deploy '#{config.name_to_s}' of type #{deploy_config.type} in #{Ros.env} environment"
        #   puts "Work dir: #{Ros.ansible_root}"
        #   Dir.chdir(Ros.ansible_root) do
        #     cmd = "ansible-playbook ./#{deploy_config.type}.yml"
        #     puts cmd
        #     # system(cmd)
        #     puts 'TODO: ansible code to invoke compose to spin up images'
        #   end
        # end

        def rollback
          # TODO: take options such as rm and so on
          compose('stop')
        end

        def compose(cmd); system_cmd(compose_env, "docker-compose #{cmd}") end

        def compose_env; @compose_env ||= {} end
      end

      def template_prefix; 'compose' end

      def deploy_path; "#{platform.nginx_host_port}" end
    end
  end
end
