# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users requests', type: :request do
  describe 'GET index' do
    let(:body) { JSON.parse(response.body) }
    context 'unauthenticated user' do
      before do
        get '/users'
      end

      it 'returns unauthenticated' do
        expect(response).to be_unauthorized
      end
    end

    context 'authenticated user' do
      before do
        tenant = create :tenant
        cr = {}
        user = create(:user, :administrator_access)
        login(user)
        cr = user.credentials.create

        headers = {
          'Content-Type' => 'application/vnd.api+json',
          'Authorization' => "Basic #{cr.access_key_id}:#{cr.secret_access_key}"
        }

        get '/users', headers: headers
      end

      xit 'returns a successful response' do
        expect(response).to be_successful
        # TODO: improve reponse test coverage
        expect(body['data']).to_not be_nil
      end
    end
  end

  describe 'POST create' do
    let(:body) { JSON.parse(response.body) }

    context 'unauthenticated user' do
      before do
        headers = { 'Content-Type' => 'application/vnd.api+json' }
        post '/users', params: '{}', headers: headers
      end

      it 'returns unauthenticated' do
        expect(response).to be_unauthorized
      end
    end

    context 'authenticated user' do
      before do
        tenant = create :tenant
        cr = {}
        user = create(:user, :administrator_access)
        login(user)
        cr = user.credentials.create
        headers = {
          'Content-Type' => 'application/vnd.api+json',
          'Authorization' => "Basic #{cr.access_key_id}:#{cr.secret_access_key}"
        }
        post '/users', params: user_data, headers: headers
      end

      context 'correct params' do
        let(:user_data) do
          '{
            "data": {
              "type": "users",
              "attributes": {
                "username": "nicolas",
                "time_zone": "SGT"
              }
            }
          }'
        end

        xit 'returns a successful response' do
          expect(response).to be_successful
          # TODO: improve reponse test coverage
          expect(response.code).to eq '201'
          expect(body['data']).to_not be_nil
        end
      end

      context 'incorrect params' do
        let(:user_data) do
          '{
            "data": {
              "type": "users",
              "attributes": {
                "username": "nicolas",
                "time_zone": "SGT",
                "jwt_payload": "hello123"
              }
            }
          }'
        end

        xit 'returns a successful response' do
          expect(response).to_not be_successful
          expect(response.code).to eq '400'
          # TODO: improve reponse test coverage
          expect(body['errors'][0]['title']).to eq('Param not allowed')
        end
      end
    end
  end
end
