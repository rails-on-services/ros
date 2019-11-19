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
      let!(:user_pool) { create(:user_pool, pool: model, user: user)}
     
      before do
        get url, headers: request_headers
      end

      context 'without users included' do
        it 'returns successful response' do
          expect(response).to have_http_status(:ok)
          expect_json_sizes('data', 1)
          expect_json('included', nil)
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
  end
end
