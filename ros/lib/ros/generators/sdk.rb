# frozen_string_literal: true

require 'thor/group'

module Ros
  module Generators
    class Sdk < Thor::Group
      include Thor::Actions
      attr_accessor :name, :options, :project
      desc 'Generate a new Ros based SDK'

      def self.source_root; Pathname(File.dirname(__FILE__)).join('../../../files').to_s end

      def generate
        gem_options = '--exe --no-coc --no-mit'
        system "bundle gem #{gem_options} #{name}_sdk"
        FileUtils.rm_rf "#{name}_sdk/.git"
      end

      def Gemfile
        # TODO: If options.dev do this; If not then declare ros_sdk as a dependency in the gemspec
        in_root do
          append_to_file 'Gemfile', after: "source \"https://rubygems.org\"\n" do <<~HEREDOC

          gem 'ros_sdk', path: '../ros/sdk'
          gem 'pry'
          gem 'awesome_print'
          HEREDOC
          end
        end
      end

      def bin_console_content
        # TODO: If options.dev do this; If not then declare ros_sdk as a dependency in the gemspec
        in_root do
          create_file 'bin/console' do <<~HEREDOC
            #!/usr/bin/env ruby

            require 'bundler/setup'
            require 'pry'
            require 'ros_sdk'
            require '#{name}_sdk'

            require 'ros_sdk/console'

            Pry.config.should_load_plugins = false
            Pry.start
            HEREDOC
          end
        end
      end

      def lib_file_content
        # TODO: If options.dev do this; If not then declare ros_sdk as a dependency in the gemspec
        in_root do
          append_to_file "lib/#{name}_sdk.rb", after: "version\"\n" do <<~HEREDOC
            require '#{name}_sdk/models'
            HEREDOC
          end
          create_file "lib/#{name}_sdk/models.rb"
        end
      end

      def gemspec_content
        gemspec = "#{name}_sdk.gemspec"
        klass = "#{name}_sdk".split('_').collect(&:capitalize).join
        in_root do
          comment_lines gemspec, 'require '
          gsub_file gemspec, "#{klass}::VERSION", "'0.1.0'"
          gsub_file gemspec, 'TODO: ', ''
          gsub_file gemspec, '~> 10.0', '~> 12.0'
          comment_lines gemspec, /spec\.homepage/
          comment_lines gemspec, /spec\.metadata/
          comment_lines gemspec, "sepc\.files"
          comment_lines gemspec, "`git"
          # append_to_file gemspec, after: "when it is released.\n  " do <<~HEREDOC
          append_to_file gemspec, after: "s)/}) }\n" do <<~HEREDOC
            spec.files         = Dir['lib/**/*.rb', 'exe/*', 'Rakefile', 'README.md'].each do |e|
            HEREDOC
          end
        end
      end

      def finish_message
        FileUtils.mv "#{name}_sdk", 'sdk'
        say "\nCreated SDK gem at #{destination_root.gsub("#{name}_sdk", 'sdk')}"
      end
    end
  end
end
