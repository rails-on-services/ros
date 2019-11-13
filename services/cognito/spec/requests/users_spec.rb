# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users requests', type: :request do
  include_context 'jsonapi requests'

  let(:tenant) { Tenant.first }
  let(:mock) { true }
  let(:base_url) { u('/users') }
  let(:url) { base_url }

  describe 'GET index' do
    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated get'
    end

    context 'authenticated user' do
      include_context 'authorized user'

      let(:models_count) { rand(1..5) }
      let!(:models) { create_list :user, models_count }

      before do
        get url, headers: request_headers
      end

      it 'returns returns an ok response status' do
        expect(response).to have_http_status(:ok)
        expect_json_sizes('data', models_count)
      end
    end

    context 'perform query' do
      include_context 'authorized user'

      let(:models_count) { rand(1..5) }
      let!(:models) { create_list :user, models_count }
      let!(:random_model) { models.last }

      context 'based on ID' do
        context 'matching query' do
          let(:url) { "#{base_url}?filter[query]=#{random_model.id}" }

          before do
            get url, headers: request_headers
          end

          it 'returns and ok response with the user ID queried' do
            expect(response).to have_http_status(:ok)
            expect_json_sizes('data', 1)
            expect_json('data.0', id: random_model.id.to_s)
          end
        end

        context 'non-matching query' do
          let(:url) { "#{base_url}?filter[query]=10" }

          before do
            get url, headers: request_headers
          end

          it 'returns and ok response, with zero response' do
            expect(response).to have_http_status(:ok)
            expect_json_sizes('data', 0)
          end
        end
      end

      context 'based on non ID attributes ' do
        let!(:model_one) { create(:user, primary_identifier: 'bananas_123') }
        let!(:model_two) { create(:user, first_name: 'bananas') }
        let!(:model_three) { create(:user, last_name: 'bananas') }
        let!(:model_four) { create(:user, email_address: 'bananas_oranges@email.com') }
        let!(:model_five) { create(:user) }

        context 'matching query' do
          let(:random_query) { 'ananas' }
          let(:url) { "#{base_url}?filter[query]=#{random_query}" }

          before do
            get url, headers: request_headers
          end

          it 'returns and ok response with the user attribute queried' do
            expect(response).to have_http_status(:ok)
            expect_json_sizes('data', 4)
          end
        end

        context 'non-matching query' do
          let(:random_query) { 'kiwi' }
          let(:url) { "#{base_url}?filter[query]=#{random_query}" }

          before do
            get url, headers: request_headers
          end

          it 'returns and ok response with the user attribute queried' do
            expect(response).to have_http_status(:ok)
            expect_json_sizes('data', 0)
          end
        end
      end
    end
  end

  describe 'GET show' do
    let!(:model) { create(:user) }
    let(:url) { "#{base_url}/#{model.id}" }

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
        expect(response).to be_ok
        expect_json('data', id: model.id.to_s)
      end
    end
  end

  describe 'POST create' do
    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated post'
    end

    context 'Authenticated user' do
      include_context 'authorized user'

      let(:model_data) { build(:user) }

      before do
        post url, headers: request_headers, params: post_data
      end

      context 'correct params' do
        let(:post_data) { jsonapi_data(model_data) }

        it 'returns a successful response with proper serialized response' do
          expect(response).to be_created
          expect_json_types('data.attributes', :object)
          expect_json('data.attributes',
                      primary_identifier: model_data.primary_identifier,
                      title: model_data.title,
                      first_name: model_data.first_name,
                      last_name: model_data.last_name,
                      phone_number: model_data.phone_number,
                      email_address: model_data.email_address,
                      anonymous: false)
        end

        describe 'when anonymous is passed as true' do
          let(:post_data) { jsonapi_data(model_data, extra_attributes: { anonymous: true }) }

          it 'returns a successful response with proper serialized response' do
            expect(response).to be_created
            expect_json_types('data.attributes', :object)
            expect_json('data.attributes',
                        primary_identifier: model_data.primary_identifier,
                        title: model_data.title,
                        first_name: model_data.first_name,
                        last_name: model_data.last_name,
                        phone_number: model_data.phone_number,
                        email_address: model_data.email_address,
                        anonymous: true)
          end
        end
      end

      context 'incorrect params' do
        let(:post_data) { jsonapi_data(model_data, extra_attributes: { invalid: :param }) }

        it 'returns a failure response and' do
          expect(errors.size).to be_positive
          expect(response).to be_bad_request
          expect(error_response.title).to eq('Param not allowed')
        end
      end
    end
  end

  describe 'PATCH update' do
    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated patch'
    end

    xcontext 'Authenticated user' do
      include_context 'authorized user'
    end

    # NOTE: We should create and extract a similar method to jsonapi_data for
    # PUT update before finalizing this part
  end

  describe 'DELETE destroy' do
    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated delete'
    end

    context 'Authenticated user' do
      include_context 'authorized user'

      let!(:model) { create(:user) }
      let(:url) { "#{base_url}/#{model.id}" }

      before do
        delete url, headers: request_headers
      end

      it 'returns returns an ok response status' do
        expect(response).to be_successful
        expect(response).to be_no_content
      end
    end
  end
end
