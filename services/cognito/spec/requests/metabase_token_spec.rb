# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'metabase token requests', type: :request do
  include_context 'jsonapi requests'

  let!(:tenant)       { Tenant.first }
  let!(:mock)         { true }
  let!(:base_url)     { service_url('/metabase_token') }
  let!(:url)          { base_url }
  let!(:user)         { create(:user) }
  let!(:card_name)    { 'total_active_customers' }
  let!(:card_id)      { rand(1..10) }
  let!(:card_record)  { create(:metabase_card, identifier: card_name, card_id: card_id) }

  describe 'Show token' do
    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated get'
    end

    context 'authenticated user' do
      include_context 'authorized user'

      context 'when a valid identifier is passed' do
        let(:url) { "#{base_url}/#{card_name}" }

        before do
          get url, headers: request_headers
        end

        it 'returns an ok response status' do
          expect(response).to be_ok
          expect_json_types('token', :string)
          token, _alg = JWT.decode(JSON.parse(response.body)['token'], nil, false)
          expect(token['resource']['question']).to eq card_id
        end
      end

      # TODO: Deprecated: Non-breaking change migration. Endpoint should only accept
      # Identifier and not id. This will be supported until FE migrates completely.
      context 'when an integer is passed' do
        let(:url) { "#{base_url}/1" }

        before do
          get url, headers: request_headers
        end

        it 'returns an ok response status' do
          expect(response).to be_ok
          expect_json_types('token', :string)
          token, _alg = JWT.decode(JSON.parse(response.body)['token'], nil, false)
          expect(token['resource']['question']).to eq 1
        end
      end

      context 'when an invalid identifier is passed' do
        let(:invalid_identifier) { 'invalid_identifier' }
        let(:url) { "#{base_url}/#{invalid_identifier}" }

        before do
          get url, headers: request_headers
        end

        it 'returns an error' do
          expect(errors.size).to be_positive
          expect(response.code.to_i).to eq 404
        end
      end
    end
  end
end
