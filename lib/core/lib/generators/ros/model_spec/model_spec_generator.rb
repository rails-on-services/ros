# frozen_string_literal: true

module Ros
  class ModelSpecGenerator < Rails::Generators::NamedBase
    def modify_files
      insert_into_file "spec/models/#{name}_spec.rb", before: 'require' do
        "# frozen_string_literal: true\n\n"
      end

      insert_into_file "spec/models/#{name}_spec.rb", after: ":model do\n" do
        "  include_examples 'application record concern' do\n"\
        "    let(:tenant) { Tenant.first }\n"\
        "    let!(:subject) { create(factory_name) }\n"\
        "  end\n\n"
      end
    end
  end
end
