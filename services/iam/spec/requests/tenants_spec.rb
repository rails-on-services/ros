require 'rails_helper'
require 'json'

RSpec.describe 'tenants requests', type: :request do
  let(:body) { JSON.parse(response.body) }

  def auth_headers
    tenant = FactoryBot.create :tenant
    cr = {}
    tenant.switch do
      user = FactoryBot.create(:user, :administrator_access)
      login(user)
      cr = user.credentials.create
    end

    return {
      'Content-Type' => 'application/vnd.api+json',
      'Authorization' => "Basic #{cr.access_key_id}:#{cr.secret_access_key}"
    }
  end

  describe 'GET /tenants' do
    context 'unauthenticated user' do
      it 'returns unauthenticated' do
        get '/tenants'

        expect(response).to be_unauthorized
      end
    end

    context 'authenticated user' do
      it 'returns a successful response' do
        get '/tenants', headers: auth_headers

        expect(response).to be_successful
        expect(body['data']).to_not be_nil
      end
    end
  end

  describe 'POST /tenants' do
    context 'unauthenticated user' do
      before do
        @headers = { 'Content-Type' => 'application/vnd.api+json' }
      end

      it 'returns unauthenticated' do
        post '/tenants', params: '{}', headers: @headers

        expect(response).to be_unauthorized
      end
    end

    context 'authenticated user' do
      before do
        @root = FactoryBot.create :root
      end

      context 'with correct params' do
        it 'returns a successful response' do
          params = {
            "data": {
              "type": "tenants",
              "attributes": {
                name: "Some Name",
                "root_id": @root.id,
                "properties": {
                  "custom_1": "cust_111"
                }
              }
            }
          }.to_json

          post '/tenants', params: params, headers: auth_headers

          expect(response).to be_successful

          expect(response.code).to eq '201'
          expect(body['data']).to_not be_nil

          expect(body['data']['attributes']['name']).to eq('Some Name')
          expect(body['data']['attributes']['account_id']).to be_truthy
          expect(body['data']['attributes']['properties']['custom_1']).to eq('cust_111')
        end
      end

      context 'with incorrect params' do
        it 'returns a successful response' do
          params = {
            "data": {
              "type": "tenants",
              "attributes": {
                "root_id": @root.id,
                "blabla": "blabla"
              }
            }
          }.to_json

          post '/tenants', params: params, headers: auth_headers

          expect(response).to_not be_successful
          expect(response.code).to eq '400'
          expect(body['errors'][0]['title']).to eq('Param not allowed')
          expect(body['errors'][0]['detail']).to eq('blabla is not allowed.')
        end
      end
    end
  end
end
