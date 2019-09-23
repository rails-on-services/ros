# frozen_string_literal: true

module SpecsGenerator
  def create_request_specs
    create_file "spec/requests/#{plural_name}_spec.rb", <<~FILE
      # frozen_string_literal: true

      require 'rails_helper'

      RSpec.describe "#{plural_name} requests", type: :request do
        let(:tenant) { Tenant.first }
        let(:mock) { true }
        let(:url) { "/#{plural_name}" }

        context 'all' do
          include_context 'jsonapi requests'

          describe 'GET index' do
            let(:models_count) { rand(5) }
            # Doesn't work yet, figure out how to create new records through factory using variables
            # let(:models) { create_list("#{name.to_sym}", models_count) }

            context 'Unauthenticated user' do
              include_context 'unauthorized user'
              include_examples 'unauthenticated get'
            end

            context 'authenticated user' do
              include_context 'authorized user'

              before do
                mock_authentication if mock
                get url, headers: request_headers
              end

              it 'returns a successful response' do
                expect(response).to have_http_status(:ok)
                # Doesn't work yet
                # expect_json_sizes('data', models_count)
              end
            end
          end
        end
      end
    FILE
  end
end
