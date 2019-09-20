# frozen_string_literal: true

module SpecsGenerator
  def create_request_specs
    create_file "spec/requests/#{plural_name}_spec.rb", <<~FILE
      # frozen_string_literal: true

      require 'rails_helper'

      RSpec.describe "#{plural_name} requests", type: :request do
      end
    FILE
  end
end
