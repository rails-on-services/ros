# frozen_string_literal: true

require 'thor/group'

module Ros
  module Generators
    class Project < Thor::Group
      include Thor::Actions
      attr_accessor :name, :options
      desc 'Generate a new Ros project'

      def self.source_root; Pathname(File.dirname(__FILE__)).join('../../../files/project').to_s end

      def clone_rails_templates
        clone_dir = Pathname(File.dirname(__FILE__)).join('../../../files').to_s
        return if Dir.exists? "#{clone_dir}/rails-templates"
        Dir.chdir(clone_dir) { %x(git clone https://github.com/rjayroach/rails-templates.git) }
      end

      def clone_repositories
        in_root do
          %x(git clone https://github.com/rails-on-services/ros.git) if options.dev
          %x(git clone https://github.com/rails-on-services/devops.git)
        end
      end

      def copy_project_files
        directory('.')
        create_file 'nginx-services.conf'
        gsub_file('Dockerfile', 'service', name)
      end

      def create_git_files
        # copy_file 'gitignore', '.gitignore'
        # copy_file 'dockerignore', '.dockerignore'
        # create_file 'images/.gitkeep'
        # create_file 'text/.gitkeep'
      end

      def create_output_directory
        in_root do
          Ros::Thing.new('env', name, options)
        end
        # TODO Test lpass integration on project setup
        # Ros::Generator.lpass(options) if options.lpass
        # empty_directory 'output'
      end

      def finish_message
        say "\nCreated Ros project at #{destination_root}"
      end
	  end
  end
end
