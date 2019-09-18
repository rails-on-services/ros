# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'tenants requests', type: :request do
  let(:body) { JSON.parse(response.body) }

  # rubocop:disable Metrics/MethodLength
  def auth_headers
    tenant = FactoryBot.create :tenant
    cr = {}
    tenant.switch do
      user = FactoryBot.create(:user, :administrator_access)
      login(user)
      cr = user.credentials.create
    end

    {
      'Content-Type' => 'application/vnd.api+json',
      'Authorization' => "Basic #{cr.access_key_id}:#{cr.secret_access_key}"
    }
  end
  # rubocop:enable Metrics/MethodLength

  describe 'GET /tenants' do
    context 'unauthenticated user' do
      it 'returns unauthenticated' do
        get '/tenants'

        expect(response).to be_unauthorized
      end
    end

    context 'authenticated user' do
      xit 'returns a successful response' do
        get '/tenants', headers: auth_headers

        expect(response).to be_successful
        expect(body['data']).to_not be_nil
      end
    end
  end

  describe 'PATCH /tenants' do
    context 'unauthenticated user' do
      before do
        @headers = { 'Content-Type' => 'application/vnd.api+json' }
      end

      it 'returns unauthenticated' do
        patch '/tenants', params: '{}', headers: @headers

        expect(response).to be_unauthorized
      end
    end

    context 'authenticated user' do
      context 'with correct params' do
        xit 'returns a successful response' do
          tenant = FactoryBot.create :tenant

          params = {
            "data": {
              "id": tenant.id.to_s,
              "type": 'tenants',
              "attributes": {
                "name": 'Some Name',
                "properties": {
                  "custom_1": 'cust_111'
                }
              }
            }
          }.to_json

          patch "/tenants/#{tenant.id}", params: params, headers: auth_headers

          expect(response).to be_successful

          expect(response.code).to eq '200'
          expect(body['data']).to_not be_nil

          expect(body['data']['attributes']['name']).to eq('Some Name')
          expect(body['data']['attributes']['account_id']).to be_truthy
          expect(body['data']['attributes']['properties']['custom_1']).to eq('cust_111')
        end
      end

      context 'trying to set readonly root_id param' do
        xit 'returns a successful response' do
          tenant = FactoryBot.create :tenant
          root = FactoryBot.create :root

          params = {
            "data": {
              "id": tenant.id.to_s,
              "type": 'tenants',
              "attributes": {
                "root_id": root.id.to_s
              }
            }
          }.to_json

          patch "/tenants/#{tenant.id}", params: params, headers: auth_headers

          expect(response).to_not be_successful
          expect(response.code).to eq '400'
          expect(body['errors'][0]['title']).to eq('Param not allowed')
          expect(body['errors'][0]['detail']).to eq('root_id is not allowed.')
        end
      end
    end
  end
end
