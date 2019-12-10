# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'pools requests', type: :request do
  include_context 'jsonapi requests'

  let(:tenant) { Tenant.first }
  let(:mock) { true }
  let(:base_url) { u('/pools') }
  let(:url) { base_url }

  describe 'GET index' do
    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated get'
    end

    context 'authenticated user' do
      include_context 'authorized user'

      let!(:model) { create(:pool) }
      let!(:user)  { create(:user) }
      let!(:user_pool) { create(:user_pool, pool: model, user: user) }

      before do
        get url, headers: request_headers
      end

      it 'includes user count for the pool' do
        expect_json('data.0.attributes.user_count', 1)
      end

      context 'without users included' do
        it 'returns successful response' do
          expect(response).to have_http_status(:ok)
          expect_json_sizes('data', 1)
        end
      end

      context 'with users included' do
        let(:url) { "#{base_url}?include=users" }

        it 'returns successful response' do
          expect(response).to have_http_status(:ok)
          expect_json_sizes('data', 1)
          expect_json_types('included', :array)
        end
      end
    end

    context 'perform query' do
      include_context 'authorized user'

      let!(:pool_name) { 'Pool-One' }
      let!(:model) { create(:pool, name: pool_name) }
      let!(:user)  { create(:user) }
      let!(:user_pool) { create(:user_pool, pool: model, user: user) }
      let!(:random_id) { model.id + 10 }

      before do
        get url, headers: request_headers
      end

      context 'based on ID' do
        context 'with match found' do
          context 'without users included' do
            let(:url) { "#{base_url}?filter[query]=#{model.id}" }

            it 'returns successful response' do
              expect(response).to have_http_status(:ok)
              expect_json_sizes('data', 1)
              expect_json('included', nil)
              expect_json('data.0.id', model.id.to_s)
            end
          end

          context 'with users included' do
            let(:url) { "#{base_url}?include=users&filter[query]=#{model.id}" }

            it 'returns successful response' do
              expect(response).to have_http_status(:ok)
              expect_json_sizes('data', 1)
              expect_json_types('included', :array)
              expect_json('data.0.id', model.id.to_s)
            end
          end
        end

        context 'with no match found' do
          context 'without users included' do
            let(:url) { "#{base_url}?filter[query]=#{random_id}" }

            it 'returns successful response with zero result' do
              expect_json_sizes('data', 0)
            end
          end

          context 'with users included' do
            let(:url) { "#{base_url}?include=users&filter[query]=#{random_id}" }

            it 'returns successful response with zero result' do
              expect_json_sizes('data', 0)
            end
          end
        end
      end

      context 'based on name' do
        context 'with match found' do
          context 'without users included' do
            let(:url) { "#{base_url}?filter[query]=#{pool_name}" }

            it 'returns successful response' do
              expect(response).to have_http_status(:ok)
              expect_json_sizes('data', 1)
              expect_json('included', nil)
              expect_json('data.0.attributes.name', pool_name)
            end
          end

          context 'with users included' do
            let(:url) { "#{base_url}?include=users&filter[query]=#{pool_name}" }

            it 'returns successful response' do
              expect(response).to have_http_status(:ok)
              expect_json_sizes('data', 1)
              expect_json_types('included', :array)
              expect_json('data.0.attributes.name', pool_name)
            end
          end
        end

        context 'with no match found' do
          context 'without users included' do
            let(:url) { "#{base_url}?filter[query]=some_random_name" }

            it 'returns successful response with zero result' do
              expect_json_sizes('data', 0)
            end
          end

          context 'with users included' do
            let(:url) { "#{base_url}?include=users&filter[query]=kiwi" }

            it 'returns successful response with zero result' do
              expect_json_sizes('data', 0)
            end
          end
        end
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
      let(:model_data) { build(:pool) }

      context 'regular pool creation' do
        before do
          mock_authentication if mock
          post url, headers: request_headers, params: post_data
        end

        context 'correct params' do
          let(:post_data) { jsonapi_data(model_data, skip_attributes: [:system_generated]) }

          it 'returns a successful response with proper serialized response' do
            expect(response).to be_created
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

      context 'segmented pool creation' do
        let(:base_pool) { create(:pool) }
        let(:birthday_user) { create(:user, birthday: Time.zone.today) }

        before do
          mock_authentication if mock
          base_pool.users << birthday_user
          post url, headers: request_headers, params: post_data
        end

        context 'correct params' do
          let(:url) { "#{base_url}/?base_pool_id=#{base_pool.id}&segments[birthday]=this_day" }
          let(:post_data) { jsonapi_data(model_data) }

          it 'returns a successful response with proper serialized response' do
            expect(response).to be_created
          end
        end
      end
    end
  end
end
