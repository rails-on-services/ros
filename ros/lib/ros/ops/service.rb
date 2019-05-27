# frozen_string_literal: true

module Ros
  module Ops
    module Service
      # Write a config for each of the service's profiles and a service env
      def configure
        FileUtils.rm_rf(service_root)
        FileUtils.mkdir_p(service_root)
        services.each_pair do |name, config|
          next if config&.enabled.eql? false
          content = service_content(name, config)
          File.write("#{service_root}/#{name}.yml", content)
          next unless envs = config.dig(:environment)
          content = Ros.format_envs('', envs).join("\n")
          File.write("#{service_root}/#{name}.env", content)
        end
        after_configure
      end

      def service_content(name, service)
        ary = []
        header_content = File.read("#{template_root}/service.yml.erb")
        ary << ERB.new(header_content).result_with_hash(template_hash)
        service.profiles.each_with_object(ary) do |profile_name, ary|
          profile_content = File.read("#{template_root}/#{profile_name}.yml.erb")
          ary << ERB.new(profile_content).result_with_hash(template_hash(name, profile_name))
        end
        ary.join('')
      end

      # NOTE: Implemented by instance
      def after_configure; end

      def service_root; "#{deploy_root}/services" end

      # TODO: implement
      def gem_version_check
        require 'bundler'
        errors = services.each_with_object([]) do |service, errors|
          config = service.last
          next if config&.enabled.eql? false
          check = image_gems_version_check(service)
          errors.append({ image: service.first, mismatches: check }) if check.size.positive?
        end
        if errors.size.positive?
          if config.force
            STDOUT.puts 'Gem version mismatch. -f used to force'
          else
            STDOUT.puts 'Gem version mismatch. Bundle update or use -f to force (build will be slower)'
            STDOUT.puts "\n#{errors.join("\n")}"
            return
          end
        end
        true
      end

      def image_gems_version_check(service)
        image = service.first
        root_dir = service.last.dig(:ros) ? "#{Ros.root}/ros" : Ros.root
        service_dir = "#{root_dir}/services/#{image}"
        definition = nil
        Dir.chdir(service_dir) do
          definition = Bundler::Definition.build('Gemfile', 'Gemfile.lock', nil)
        end
        gems = definition.requested_specs.select{ |s| images.static_gems.keys.include?(s.name.to_sym) }
        gems.each_with_object([]) do |gemfile_gem, errors|
          gemfile_version = gemfile_gem.version
          image_version = Gem::Version.new(images.static_gems[gemfile_gem.name.to_sym])
          next if gemfile_version.eql?(image_version)
          errors << { image: image, name: gemfile_gem.name, image_version: image_version.to_s, gemfile_version: gemfile_version.to_s }
        end
      end
    end
  end
end
