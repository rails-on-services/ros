# frozen_string_literal: true

module Ros
  class Instance < Deployment
    def template_prefix; 'compose' end

    def service_config(profile)
      {
        command: profile.command,
        # rails_env: image.rails_env,
        # os_packages: image.os_packages,
        # tag: "#{image.rails_env}-#{sha}",
        mount: profile.mount || false
      }
    end

    def deploy_path; deployment.target end # #{name}/#{deployment.target}/#{deployment.image}"

    def write_platform_services
      content = File.read("#{template_root}/platform.yml.erb")
      content = ERB.new(content).result_with_hash({ server_keys: server_keys })
      File.write("#{deploy_root}/platform.yml", content)
    end

    def server_keys; services.to_h.select { |k, v| v.profiles.include? 'server' }.keys end

    def write_env
      content = deploy_env.each_with_object([]) do |kv, ary|
        ary << "#{kv[0].upcase}=#{kv[1]}"
      end.join("\n")
      content = "# .env\n# This file was auto generated\n# Compose Variables\n#{content}"
      File.write("#{Ros.root}/env-it", content)
    end

    def deploy_env
      {
        compose_file: Dir["#{deploy_root}/**.yml"].map{ |p| p.gsub("#{Ros.root}/", '') }.join(':'),
        compose_project_name: environment.partition_name,
        context_dir: '..',
        # IMAGE_REPOSITORY=rails-on-services
        # IMAGE_TAG=0.1.0-master-d6c051f
        nginx_host_port: 3000,
        image_repository: image.registry,
        rails_env: image.rails_env,
        os_packages: image.os_packages.join(' '),
        image_tag: "#{image.rails_env}-#{sha}"
      }
    end
  end
end
