# frozen_string_literal: true

require 'thor/group'

module Ros
  module Generators
    class CoreGenerator < Thor::Group
      include Thor::Actions
      argument :name

      def self.source_paths; ["#{File.dirname(__FILE__)}/templates", File.dirname(__FILE__)] end

      def generate
        return unless self.behavior.eql? :invoke
        template_file = "#{File.dirname(__FILE__)}/rails/core_generator.rb"
        rails_options = '--api -G -S -J -C -T -M --database=postgresql --skip-active-storage'
        plugin_options = '--full --dummy-path=spec/dummy'
        exec_system = "rails plugin new #{rails_options} #{plugin_options} -m #{template_file} #{name}-core"
        puts exec_system
        inside('lib') do
          system exec_system
          FileUtils.mv "#{name}-core", 'core'
        end
      end

      # NOTE: This could be in the rails template
      # def gemspec_content
      #   gemspec = "#{name}-core.gemspec"
      #   klass = "#{name}-core".split('-').collect(&:capitalize).join('::')
      #   inside 'lib/core' do
      #     comment_lines gemspec, 'require '
      #     gsub_file gemspec, "#{klass}::VERSION", "'0.1.0'"
      #     gsub_file gemspec, 'TODO: ', ''
      #   end
      # end

      def finish_message
        action = self.behavior.eql?(:invoke) ? 'Created' : 'Destroyed'
        say "\n#{action} core gem at #{destination_root}/lib/core"
      end
    end
  end
end
