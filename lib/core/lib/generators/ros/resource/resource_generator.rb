# frozen_string_literal: true

require_relative '../generators_helper.rb'

module Ros
  class ResourceGenerator < Rails::Generators::NamedBase
    include GeneratorsHelper

    def create_files
      create_file "app/resources/#{name}_resource.rb", <<~FILE
        # frozen_string_literal: true

        class #{name.classify}Resource < #{parent_module}ApplicationResource
          attributes #{args.reject { |a| a.split(':').last.in? %w[references belongs_to] }.map { |e| ':' + e.split(':').first }.join(', ')}
          has_one #{args.select { |a| a.split(':').last.in? %w[references belongs_to] }.map { |e| ':' + e.split(':').first }.join(', ')}
        end
      FILE
    end
  end
end
