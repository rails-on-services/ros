# frozen_string_literal: true

require_relative '../generators_helper.rb'

module Ros
  class ModelGenerator < Rails::Generators::NamedBase
    include GeneratorsHelper

    def create_files
      invoke(:model)

      gsub_file(
        "app/models/#{name}.rb",
        'ApplicationRecord',
        "#{parent_module}ApplicationRecord"
      )

      insert_into_file "spec/models/#{name}_spec.rb", after: ":model do\n" do
        "  include_examples 'application record concern' do\n"\
        "    let(:tenant) { Tenant.first }\n"\
        "    let!(:subject) { create(factory_name) }\n"\
        "  end\n\n"
      end
    end
  end
end
