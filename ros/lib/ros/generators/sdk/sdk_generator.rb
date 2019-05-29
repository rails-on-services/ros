# frozen_string_literal: true

require 'thor/group'

module Ros
  module Generators
    class SdkGenerator < Thor::Group
      include Thor::Actions
      argument :name

      def self.source_paths; ["#{File.dirname(__FILE__)}/templates", File.dirname(__FILE__)] end

      def generate
        return unless self.behavior.eql? :invoke
        gem_options = '--exe --no-coc --no-mit'
        inside 'lib' do
          system "bundle gem #{gem_options} #{name}_sdk"
          FileUtils.mv "#{name}_sdk", 'sdk'
          FileUtils.rm_rf 'sdk/.git'
        end
      end

      def gemfile
        inside 'lib/sdk' do
          append_to_file 'Gemfile', after: "source \"https://rubygems.org\"\n" do <<~HEREDOC

          gem 'ros_sdk', path: '../../ros/lib/sdk'
          gem 'pry'
          gem 'awesome_print'
          HEREDOC
          end
          remove_file "lib/#{name}_sdk/version.rb"
          remove_file 'bin/console'
          # template 'bin/console.erb', 'bin/console'
        end
      end

      def lib_file_content
        inside 'lib/sdk/lib' do
          create_file "#{name}_sdk/models.rb"
          append_to_file "#{name}_sdk.rb", after: "version\"\n" do <<~HEREDOC
            require '#{name}_sdk/models'
            HEREDOC
          end
        end
      end

      def gemspec_content
        gemspec = "#{name}_sdk.gemspec"
        klass = "#{name}_sdk".split('_').collect(&:capitalize).join
        inside 'lib/sdk' do
          comment_lines gemspec, 'require '
          gsub_file gemspec, "#{klass}::VERSION", "'0.1.0'"
          gsub_file gemspec, 'TODO: ', ''
          gsub_file gemspec, '~> 10.0', '~> 12.0'
          comment_lines gemspec, /spec\.homepage/
          comment_lines gemspec, /spec\.metadata/
          comment_lines gemspec, /spec\.files/
          comment_lines gemspec, "`git"
          # append_to_file gemspec, after: "when it is released.\n  " do <<~HEREDOC
          append_to_file gemspec, after: "s)/}) }\n" do <<~HEREDOC
            spec.files         = Dir['lib/**/*.rb', 'exe/*', 'Rakefile', 'README.md'].each do |e|
            HEREDOC
          end
        end
      end

      def finish_message
        action = self.behavior.eql?(:invoke) ? 'Created' : 'Destroyed'
        say "\n#{action} SDK gem at #{destination_root}/lib/sdk"
      end
    end
  end
end
