# frozen_string_literal: true

module Ros
  module Ops
    module Platform
      # Write the configuration files, e.g. skaffold, compose, etc
      def configure
        FileUtils.rm_rf(platform_root)
        FileUtils.mkdir_p(platform_root)
        configure_basic_services
        configure_env
        write_service_content
      end

      def platform_root; "#{deploy_root}/platform" end

      def configure_basic_services
        platform.basic_services.keys.each do |name|
          content = File.read("#{template_root}/#{name}.yml.erb")
          content = ERB.new(content).result_with_hash(template_hash(name))
          File.write("#{platform_root}/#{name}.yml", content)
          if envs = platform.basic_services.dig(name, :environment)
            content = format_envs('', envs).join("\n")
            File.write("#{platform_root}/#{name}.env", content)
          end
        end
      end

      def configure_env
        envs = platform.environment.dup.merge!(environment)
        ary = format_envs(:platform, envs)
        content = format_envs('', platform.services.environment, ary).join("\n")
        File.write("#{platform_root}/platform.env", content)
      end

      # NOTE: Implemented by instance
      def write_service_content
        platform.basic_services.keys.each do |service|
          send("write_#{service}") if respond_to? "write_#{service}".to_sym
        end
      end

      def environment
        {
          # secret_key_base: ENV['SECRET_KEY_BASE'],
          # rails_master_key: ENV['RAILS_MASTER_KEY'],
          jwt: {
            # encryption_key: ENV['PLATFORM__ENCRYPTION_KEY'],
            iss: "#{uri.scheme}://iam.#{uri.to_s.split('//').last}",
            aud: uri.to_s
          },
          # PLATFORM__CREDENTIAL__SALT
          # PLATFORM__CONNECTION__TYPE=host
          # PLATFORM__EXTERNAL_CONNECTION_TYPE=path
          hosts: uri.to_s.split('//').last,
          postman: {
            workspace: uri.to_s.split('//').last,
            # api_key: ENV['PLATFORM__POSTMAN__API_KEY']
          },
          api_docs: {
            server: {
              host: uri.to_s
            }
          }
        }
      end

        def write_fluentd
          content = File.read("#{template_services_root}/fluentd/requests.conf.erb")
          content = ERB.new(content).result_with_hash(fluentd_env)
          content_dir = "#{platform_root}/fluentd"
          FileUtils.mkdir_p("#{content_dir}/log")
          FileUtils.chmod('+w', "#{content_dir}/log")
          FileUtils.mkdir_p("#{content_dir}/etc")
          File.write("#{content_dir}/etc/requests.conf", content)
        end

        def fluentd_env
          {
            header: fluentd_header,
            log_tag: "#{api_hostname}.rack-traffic-log",
            provider: infra.provider,
            config: {
              bucket: "#{api_hostname}-#{platform.basic_services.dig(:fluentd, :config, :bucket)}",
              region: infra.aws_region
            }
          }
        end
        def fluentd_header; '' end
    end
  end
end
