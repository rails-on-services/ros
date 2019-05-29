# frozen_string_literal: true

require 'thor/group'

module Ros
  module Generators
    class ServiceGenerator < Thor::Group
      include Thor::Actions
      argument :name
      argument :project

      def self.source_paths; ["#{File.dirname(__FILE__)}/templates", File.dirname(__FILE__)] end

      # TODO: db and dummy path are set from config values
      def generate
        return unless self.behavior.eql? :invoke
        return if Dir.exists?("services/#{name}")
        template_file = "#{File.dirname(__FILE__)}/rails/service_generator.rb"
        plugin = Ros.is_ros? ? 'plugin' : ''
        rails_options = '--api -G -S -J -C -T -M --database=postgresql --skip-active-storage'
        plugin_options = Ros.is_ros? ? '--full --dummy-path=spec/dummy' : ''
        prefix = Ros.is_ros? ? 'ros-' : ''
        service_name = "#{prefix}#{name}"
        exec_system = "rails #{plugin} new #{rails_options} #{plugin_options} -m #{template_file} #{service_name}"
        puts exec_system
        Dir.chdir('services') do
          system exec_system
          FileUtils.mv(service_name, name) if Ros.is_ros?
        end
      end

      def sdk_content
        append_file "lib/sdk/lib/#{project}_sdk/models.rb", <<~RUBY
          require '#{project}_sdk/models/#{name}.rb'
        RUBY

        create_file "lib/sdk/lib/#{project}_sdk/models/#{name}.rb", <<~RUBY
          # frozen_string_literal: true

          module #{project.split('_').collect(&:capitalize).join}
            module #{name.split('_').collect(&:capitalize).join}
              class Client < Ros::Platform::Client; end
              class Base < Ros::Sdk::Base; end

              class Tenant < Base; end
            end
          end
        RUBY
      end

      def finish_message
        FileUtils.rm_rf(destination_root) if self.behavior.eql? :revoke
        action = self.behavior.eql?(:invoke) ? 'Created' : 'Destroyed'
        say "\n#{action} service at #{destination_root}"
      end
    end
  end
end
