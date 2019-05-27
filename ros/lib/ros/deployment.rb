# frozen_string_literal: true
require 'bump'

module Ros
  class Deployment
    attr_accessor :meta, :platform, :services, :providers, :infra, :profiles, :images
    attr_accessor :provider, :image
    attr_accessor :options # CLI options

    def initialize(options)
      self.options = options
      %i(meta platform services providers infra profiles images).each do |type|
        self.send("#{type}=", Settings.send(type))
      end
      %i(provider image).each do |type|
        self.send("#{type}=", Settings.send("#{type}s").dig(*Settings.meta.components.send(type).split('/')))
      end
      infra.provider = Settings.meta.components.provider.split('/').first 
      infra.type = Settings.meta.components.provider.split('/').last
    end

    # def provider_name; @provider_name ||= end
    # def provider_type; @provider_type ||= Settings.meta.components.provider.split('/').last end
    # def image_name; @image_nmae ||= Settings.meta.components.image end

    def template_hash(name = '', profile = ''); template_vars(name, profile).merge(base_vars) end
    def template_vars(name, profile); {} end
    def base_vars; { infra: infra, platform: platform, services: services, profiles: profiles, images: images } end

    def uri; URI("#{infra.endpoint.scheme}://#{api_hostname}") end

    def api_hostname
      @api_hostname ||=
        if infra.branch_deployments
          branch_name.eql?(infra.api_branch) ? infra.endpoint.host : "#{branch_name}-#{infra.endpoint.host}"
        else
          infra.endpoint.host
        end + ".#{infra.dns.subdomain}.#{infra.dns.domain}"
    end

    def version; Bump::Bump.current end
    def image; images[Settings.meta.components.image] end
    # def image; images[platform.services.image] end
    def image_tag; "#{version}-#{sha}#{image_suffix}" end
    def image_suffix; image.build_args.rails_env.eql?('production') ? '' : "-#{image.build_args.rails_env}" end

    def branch_name
      return unless system('git rev-parse --git-dir > /dev/null 2>&1')
      @branch_name ||= %x(git rev-parse --abbrev-ref HEAD).strip.gsub(/[^A-Za-z0-9-]/, '-')
    end

    def sha
      return @sha if @sha
      return unless system('git rev-parse --git-dir > /dev/null 2>&1')
      @sha = %x(git rev-parse --short HEAD).chomp
    end

    def deploy_root; @deploy_root ||= "#{Ros.root}/tmp/deployments/#{deploy_path}" end
    def relative_path_from_root; @relative_path_from_root ||= deploy_root.gsub("#{Ros.root}/", '') end
    def relative_path; @relative_path ||= ('../' * deploy_root.gsub("#{Ros.root}/", '').split('/').size).chomp('/') end
    def template_root; @template_root ||= Pathname(__FILE__).join("../../../assets/deployment/#{template_prefix}") end
    def template_services_root; @template_services_root ||= Pathname(__FILE__).join("../../../assets/deployment/services") end

    def system_cmd(env, cmd)
      puts "Running #{cmd}"
      system(env, cmd) unless options.noop
    end
  end
end
