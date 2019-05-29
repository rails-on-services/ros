# frozen_string_literal: true

require 'thor/group'

module Ros
  module Generators
    class Service
      attr_accessor :action, :args, :options

      def initialize(action, args, options)
        self.action = action
        self.args = args
        self.options = options
      end

      def execute
        name = args.first
        generator = ServiceGenerator.new
        generator.name = name
        generator.options = options
        generator.destination_root = "services/#{name}"
        generator.project = File.basename(Dir.pwd)
        generator.invoke_all
      end
    end

    class ServiceGenerator < Thor::Group
      include Thor::Actions
      attr_accessor :name, :options, :project
      desc 'Generate a new Ros service'

      def self.source_root; Pathname(File.dirname(__FILE__)).join('../../../assets').to_s end

      def generate
        return unless self.behavior.eql? :invoke
        return if Dir.exists?("services/#{name}")
        template_file = "#{self.class.source_root}/service/templates/application.rb"
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
        append_file "../sdk/lib/#{project}_sdk/models.rb", <<~HEREDOC
          require '#{project}_sdk/models/#{name}.rb'
        HEREDOC

        create_file "../sdk/lib/#{project}_sdk/models/#{name}.rb", <<~HEREDOC
          # frozen_string_literal: true

          module #{project.split('_').collect(&:capitalize).join}
            module #{name.split('_').collect(&:capitalize).join}
              class Client < Ros::Platform::Client; end
              class Base < Ros::Sdk::Base; end

              class Tenant < Base; end
            end
          end
        HEREDOC
      end

      def finish_message
        FileUtils.rm_rf(destination_root) if self.behavior.eql? :revoke
        action = self.behavior.eql?(:invoke) ? 'Created' : 'Destroyed'
        say "\n#{action} service at #{destination_root}"
      end
    end
  end
end
