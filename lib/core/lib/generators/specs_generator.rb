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
            let(:models_count) { rand(1..5) }
            let!(:models) { tenant.switch { create_list(:#{name}, models_count) } }

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

              it 'returns returns an ok response status' do
                expect(response).to have_http_status(:ok)
                expect_json_sizes('data', models_count)
              end
            end
          end

          describe 'GET show' do
            let!(:model) { tenant.switch { create(:#{name}) } }
            let(:show_url) { url + '/' + model.id.to_s }

            context 'Unauthenticated user' do
              include_context 'unauthorized user'
              include_examples 'unauthenticated get'
            end

            context 'authenticated user' do
              include_context 'authorized user'

              before do
                mock_authentication if mock
                get show_url, headers: request_headers
              end

              it 'returns returns an ok response status' do
                expect(response).to be_ok
                expect_json('data', id: model.id.to_s)
              end
            end
          end

          xdescribe 'POST create' do
            context 'Unauthenticated user' do
              include_context 'unauthorized user'
              include_examples 'unauthenticated get'
            end

            xcontext 'Authenticated user' do
              include_context 'authorized user'

              # Make this a helper method on lib/core/spec/support/helpers/json_helper.rb
              # def jsonapi_data(object, remove = false, *except_attributes)
              #   args = %i[id created_at updated_at]
              #   except_attributes.append(*args) if remove

              #   {
              #     data: {
              #       type: object.class.name.underscore.pluralize,
              #       attributes: object.attributes.except(*except_attributes.map(&:to_s))
              #     }
              #   }.to_json
              # end

              let(:model_data) { build("#{name.to_sym}") }

              before do
                mock_authentication if mock
                allow(Perx::Outcome::RequestOutcome).to receive(:create).and_return(results)
              end

              xcontext 'correct params' do
                it 'returns a successful response with proper serialized response' do
                  post_data = jsonapi_data(model_data, true)
                  post url, headers: request_headers, params: post_data

                  expect(response).to be_created
                  expect(model_data.content).to eq(post_response.content)
                  expect(model_data.campaign_entity_id).to eq(post_response.campaign_entity_id)
                  expect(model_data.engagement_id).to eq(post_response.engagement_id)
                end
              end

              xcontext 'incorrect params' do
                it 'returns a successful response with proper serialized response' do
                  post_data = jsonapi_data(model_data, false)
                  post url, headers: request_headers, params: post_data

                  expect(errors.size).to be_positive
                  expect(response).to be_bad_request
                  expect(error_response.title).to eq('Param not allowed')
                end
              end
            end
          end
        end
      end
    FILE
  end
end
