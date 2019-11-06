# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'public_keys requests', type: :request, exclude: true do
  let(:tenant) { Tenant.first }
  let(:mock) { true }
  let(:url) { '/public_keys' }

  context 'all' do
    include_context 'jsonapi requests'

    describe 'GET index' do
      let(:models_count) { rand(1..5) }
      let!(:models) { create_list(:public_key, models_count) }

      context 'Unauthenticated user' do
        include_context 'unauthorized user'
        include_examples 'unauthenticated get'
      end

      context 'authenticated user' do
        include_context 'authorized user'

        before do

          get url, headers: request_headers
        end

        it 'returns returns an ok response status' do
          expect(response).to have_http_status(:ok)
          expect_json_sizes('data', models_count)
        end
      end
    end

    describe 'GET show' do
      let!(:model) { create(:public_key) }
      let(:show_url) { url + '/' + model.id.to_s }

      context 'Unauthenticated user' do
        include_context 'unauthorized user'
        include_examples 'unauthenticated get'
      end

      context 'authenticated user' do
        include_context 'authorized user'

        before do

          get show_url, headers: request_headers
        end

        it 'returns returns an ok response status' do
          expect(response).to be_ok
          expect_json('data', id: model.id.to_s)
        end
      end
    end

    describe 'POST create' do
      context 'Unauthenticated user' do
        include_context 'unauthorized user'
        include_examples 'unauthenticated get'
      end

      context 'Authenticated user' do
        include_context 'authorized user'

        let(:model_data) { build(:public_key) }

        before do

        end

        context 'correct params' do
          it 'returns a successful response with proper serialized response' do
            post_data = jsonapi_data(model_data)
            post url, headers: request_headers, params: post_data

            expect(response).to be_created
            # NOTE: Test if model data attribute matches response attributes
            # expect(model_data.attribute1).to eq(post_response.attribute1)
            # expect(model_data.attribute2).to eq(post_response.attribute2)
          end
        end

        context 'incorrect params' do
          it 'returns a failure response and' do
            post_data = jsonapi_data(model_data, extra_attributes: { invalid: :param })
            post url, headers: request_headers, params: post_data

            expect(errors.size).to be_positive
            expect(response).to be_bad_request
            expect(error_response.title).to eq('Param not allowed')
          end
        end
      end
    end

    describe 'PUT update' do
      context 'Unauthenticated user' do
        include_context 'unauthorized user'
        include_examples 'unauthenticated get'
      end

      context 'Authenticated user' do
        include_context 'authorized user'
      end

      # NOTE: We should create and extract a similar method to jsonapi_data for PUT update before finalizing this part
    end

    describe 'DELETE destroy' do
      context 'Unauthenticated user' do
        include_context 'unauthorized user'
        include_examples 'unauthenticated get'
      end

      context 'Authenticated user' do
        include_context 'authorized user'

        let!(:model) { create(:public_key) }
        let(:delete_url) { url + '/' + model.id.to_s }

        before do

          delete delete_url, headers: request_headers
        end

        it 'returns returns an ok response status' do
          expect(response).to be_no_content
        end
      end
    end
  end
end
