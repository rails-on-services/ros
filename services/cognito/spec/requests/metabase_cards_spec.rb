# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'metabase_cards requests', type: :request do
  include_context 'jsonapi requests'

  let(:tenant) { Tenant.first }
  let(:mock) { true }
  let(:base_url) { u('/metabase_cards') }
  let(:url) { base_url }

  describe 'POST create' do
    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated get'
    end

    context 'Authenticated user' do
      include_context 'authorized user'

      let(:model_data) { build(:metabase_card) }

      before do
        mock_authentication if mock
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

      context 'record with duplicate card id' do
        before do
          create(:metabase_card, card_id: model_data.card_id)
        end

        it 'returns a failure response' do
          post_data = jsonapi_data(model_data)
          post url, headers: request_headers, params: post_data

          expect(errors.size).to be_positive
        end
      end

      context 'record with duplicate uniq identifier' do
        before do
          create(:metabase_card, uniq_identifier: model_data.uniq_identifier)
        end

        it 'returns a failure response' do
          post_data = jsonapi_data(model_data)
          post url, headers: request_headers, params: post_data

          expect(errors.size).to be_positive
        end
      end
    end
  end
end
