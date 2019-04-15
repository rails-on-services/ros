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
        template_dir = Pathname(File.dirname(__FILE__)).join('../../../files/rails-templates').to_s
        rails_options = '--full --api --dummy-path=spec/dummy -S -J -C -T -M'
        system "rails plugin new #{rails_options} -m #{template_dir}/6-api.rb #{name}-core"
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
        FileUtils.mv "#{name}-core", 'core'
        say "\nCreated Core gem at #{destination_root}"
      end
    end
  end
end
