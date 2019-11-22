# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'metabase token requests', type: :request do
  include_context 'jsonapi requests'

  let!(:tenant)       { Tenant.first }
  let!(:mock)         { true }
  let!(:base_url)     { u('/metabase_token') }
  let!(:url)          { base_url }
  let!(:user)         { create(:user) }
  let!(:card_name)    { 'total_active_customers' }
  let!(:card_id)      { rand(1..10) }
  let!(:card_record)  { create(:metabase_card_identifier_record, uniq_identifier: card_name, card_id: card_id) }


  describe 'GET show' do
    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated get'
    end

    context 'authenticated user' do
      include_context 'authorized user'

      let(:url)       { "#{base_url}/#{card_id}?identifier=#{card_name}" }

      before do
        get url, headers: request_headers
      end

      it 'returns an ok response status' do
        expect(response).to be_ok
        expect_json_types('token', :string)
      end
    end
  end
end
