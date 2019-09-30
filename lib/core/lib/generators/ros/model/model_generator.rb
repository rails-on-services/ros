# frozen_string_literal: true

require_relative '../generators_helper.rb'

module Ros
  class ModelGenerator < Rails::Generators::NamedBase
    include GeneratorsHelper

    def create_files
      invoke(:model)

      gsub_created_file
      insert_spec_default_template_into_file
    end

    private

    def gsub_created_file
      gsub_file(
        "app/models/#{name}.rb",
        'ApplicationRecord',
        "#{parent_module}ApplicationRecord"
      )
    end

    def insert_spec_default_template_into_file
      insert_into_file "spec/models/#{name}_spec.rb", after: ":model do\n" do
        "  include_examples 'application record concern' do\n"\
        "    let(:tenant) { Tenant.first }\n"\
        "    let!(:subject) { create(factory_name) }\n"\
        "  end\n\n"
      end
    end
  end
end
