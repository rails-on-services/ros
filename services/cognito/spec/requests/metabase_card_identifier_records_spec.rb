# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'metabase card identifier record requests', type: :request do
  include_context 'jsonapi requests'

  let!(:tenant)       { Tenant.first }
  let!(:mock)         { true }
  let!(:base_url)     { u('metabase_card_identifier_records') }
  let!(:url)          { base_url }



  describe 'POST create' do
    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated get'
    end

    context 'authenticated user' do
      include_context 'authorized user'

      let(:model_data) { build(:metabase_card_identifier_record) }

      before do
        mock_authentication if mock
        post url, headers: request_headers, params: post_data
      end

      context 'when valid params are passed' do
        let(:post_data) { jsonapi_data(model_data) }

        it 'returns a successful response' do
          expect(response).to be_successful
        end
      end

      context 'when invalid params are passed' do
      end

      context 'when a similar record exists' do
      end
    end
  end
end
