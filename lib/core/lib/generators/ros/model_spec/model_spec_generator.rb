# frozen_string_literal: true

module Ros
  class ModelSpecGenerator < Rails::Generators::NamedBase
    def create_files
      create_file "spec/models/#{name}_spec.rb", <<~FILE
        # frozen_string_literal: true

        require 'rails_helper'

        RSpec.describe #{name.classify}, type: :model do
          include_examples 'application record concern' do
            let(:tenant) { Tenant.first }
            let!(:subject) { create(:#{name}) }
          end

          pending "add more examples"
        end
      FILE
    end
  end
end
