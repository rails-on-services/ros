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

      context 'when valid params are passed' do
      end

      context 'when invalid params are passed' do
      end

      context 'when a similar record exists' do
      end
    end
  end
end
