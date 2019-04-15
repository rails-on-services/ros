# frozen_string_literal: true

require 'thor/group'

module Ros
  module Generators
    class Project < Thor::Group
      include Thor::Actions
      attr_accessor :name, :options
      desc 'Generate a new Ros project'

      def self.source_root; Pathname(File.dirname(__FILE__)).join('../../../files').to_s end

      def clone_repositories
        base_url = options.dev ? 'git@github.com:' : 'https://github.com/'
        unless Dir.exists? "#{self.class.source_root}/rails-templates"
          Dir.chdir(self.class.source_root) { %x(git clone #{base_url}rjayroach/rails-templates.git) }
        end
        in_root do
          %x(git clone git@github.com:rails-on-services/ros.git) if options.dev
          %x(git clone #{base_url}rails-on-services/devops.git)
          system 'bundle install'
        end
      end

      def create_ros_services
        return if options.dev
        # TODO for each ros service gem, generate a rails application that includes that gem
      end

      def finish_message
        say "\nCreated Ros project at #{destination_root}"
      end
	  end
  end
end
