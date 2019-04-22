# frozen_string_literal: true

require 'thor/group'

module Ros
  module Generators
    class Core < Thor::Group
      include Thor::Actions
      attr_accessor :name, :options, :project
      desc 'Generate a new Ros based Core gem'

      def self.source_root; Pathname(File.dirname(__FILE__)).join('../../../files').to_s end

      def generate
        template_file = "#{self.class.source_root}/rails-templates/6-api.rb"
        rails_options = '--full --api --dummy-path=spec/dummy -S -J -C -T -M'
        exec_system = "rails plugin new #{rails_options} -m #{template_file} #{name}-core"
        puts exec_system
        Dir.chdir('services') { system exec_system }
      end

      # NOTE: This could be in the rails template
      def gemspec_content
        gemspec = "#{name}-core.gemspec"
        klass = "#{name}-core".split('-').collect(&:capitalize).join('::')
        in_root do
          comment_lines gemspec, 'require '
          gsub_file gemspec, "#{klass}::VERSION", "'0.1.0'"
          gsub_file gemspec, 'TODO: ', ''
        end
      end

      def finish_message
        Dir.chdir('services') do
          FileUtils.mv "#{name}-core", 'core'
        end
        action = self.behavior.eql?(:invoke) ? 'Created' : 'Destroyed'
        say "\n#{action} core gem at #{destination_root}"
      end
    end
  end
end
