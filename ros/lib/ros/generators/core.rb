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
        %x(rails plugin new #{rails_options} -m #{template_dir}/6-api.rb #{name})
      end

      def finish_message
        say "\nCreated Ros service at #{destination_root}"
      end
    end
  end
end
