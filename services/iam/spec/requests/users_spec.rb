# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users requests', type: :request do
  let(:url) { '/users' }
  let(:tenant) { create(:tenant) }
  let(:admin_user) { create(:user, :administrator_access) }
  let(:admin_creds) { admin_user.credentials.create }
  let(:normal_user) { create(:user) }
  let(:normal_creds) { normal_user.credentials.create }
  let(:headers) do
    {
      'Content-Type' => 'application/vnd.api+json',
      'Authorization' => "Basic #{admin_creds.access_key_id}:#{admin_creds.secret_access_key}"
    }
  end

  # The jsonapi_data helper creates a valid user which includes a lot of
  # properties that are invalid as part of generating a new user so we
  # construct it manually instead
  let(:valid_params) do
    { data: { type: 'users',
              attributes: {
                username: 'nicolas',
                email: 'foo@example.com',
                time_zone: 'SGT'
              } } }
  end
  let(:invalid_params) do
    valid_params.deep_merge(data: { attributes: { jwt_payload: 'foo' } })
  end

  include_context 'jsonapi requests'

  describe 'GET index' do
    context 'unauthenticated user' do
      before(:each) do
        get url
      end

      it 'returns unauthenticated' do
        expect(response).to be_unauthorized
      end
    end

    context 'authenticated user' do
      before do
        login(admin_user)
        get '/users', headers: headers
      end

      it 'returns a successful response' do
        expect(response).to be_successful
        # TODO: improve reponse test coverage
        expect(body['data']).to_not be_nil
      end
    end
  end

  describe 'POST create' do
    context 'unauthenticated user' do
      let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }

      before do
        post url, params: '{}', headers: headers
      end

      it 'returns unauthenticated' do
        expect(response).to be_unauthorized
      end
    end

    context 'authenticated normal user' do
      let(:user_data) { valid_params.to_json }

      before do
        login(normal_user)
      end

      it 'returns permission denied when creating another user' do
        post url, params: user_data, headers: headers
        expect(response).to_not be_successful
      end
    end

    context 'authenticated admin user' do
      before do
        login(admin_user)
      end

      context 'correct params' do
        let(:user_data) { valid_params.to_json }

        it 'returns a successful response' do
          post url, params: user_data, headers: headers
          expect(response).to be_successful
          # TODO: improve reponse test coverage
          expect(response.code).to eq '201'
          expect(body['data']).to_not be_nil
        end

        it 'creates as user' do
          expect do
            post url, params: user_data, headers: headers
          end.to change {
            User.count
          }.by 1
        end

        it 'does not activate the newly created user' do
          post url, params: user_data, headers: headers
          expect(User.find_by(email: valid_params[:data][:attributes][:email]).confirmed_at).to be_nil
        end
      end

      context 'incorrect params' do
        let(:user_data) { invalid_params.to_json }

        it 'returns an unsuccessful response' do
          post url, params: user_data, headers: headers
          expect(response).to_not be_successful
          expect(response.code).to eq '400'
          # TODO: improve reponse test coverage
          expect(body['errors'][0]['title']).to eq('Param not allowed')
        end
      end
    end
  end
end
