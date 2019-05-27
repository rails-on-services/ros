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

      # def one_service?
      #   services = Dir['services/*'] - ['services/core', 'services/sdk']
      #   services.size.eql?(1) and services.first.eql? "services/#{name}"
      # end

      def generate
        return unless self.behavior.eql? :invoke
        template_file = "#{self.class.source_root}/rails-templates/6-api.rb"
        rails_options = '--api -S -J -C -T -M'
        exec_system = "rails new #{rails_options} -m #{template_file} #{name}"
        puts exec_system
        Dir.chdir('services') { system exec_system }
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
