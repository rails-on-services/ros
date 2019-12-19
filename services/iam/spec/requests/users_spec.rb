# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users requests', type: :request do
  include_context 'jsonapi requests'

  let(:url) { u('/users') }
  let(:tenant) { create(:tenant) }
  let(:admin_user) { create(:user, :administrator_access) }
  let(:admin_creds) { admin_user.credentials.create }
  let(:admin_group) { create(:group, users: [admin_user]) }
  let(:normal_user) { create(:user) }
  let(:headers) do
    {
      'Content-Type' => 'application/vnd.api+json',
      'Authorization' => "Basic #{admin_creds.access_key_id}:#{admin_creds.secret_access_key}"
    }
  end

  describe 'GET index' do
    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated get'
    end

    context 'authenticated user' do
      before do
        normal_user
        login(admin_user)
        get url, headers: headers
      end

      it 'returns a successful response' do
        expect(response).to be_successful
        expect_json_types('data', :array)
        expect_json('data.0.id', normal_user.id.to_s)
        expect_json('data.1.id', admin_user.id.to_s)
      end

      context 'filtered search' do
        let(:url) { u("/users?filter[groups]=#{admin_group.id}") }

        it 'filters the users that belong to group id' do
          expect(response).to be_successful
          expect_json_types('data', :array)
          expect_json_sizes('data', 1)
          expect_json('data.0.id', admin_user.id.to_s)
        end
      end
    end
  end

  # NOTE: The jsonapi_data helper creates a valid user which includes a lot of
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
      let(:request) { post url, params: user_data, headers: headers }
      before do
        login(admin_user)
      end

      context 'correct params' do
        let(:user_data) { valid_params.to_json }

        it 'returns a successful response' do
          request
          expect(response).to be_successful
          # TODO: improve reponse test coverage
          expect(response.code).to eq '201'
          expect(body['data']).to_not be_nil
        end

        it 'creates as user' do
          expect { request }.to change { User.count }.by 1
        end

        it 'does not activate the newly created user' do
          request
          expect(User.find_by(email: valid_params[:data][:attributes][:email]).confirmed_at).to be_nil
        end
      end

      # TODO: skip unless we'll deal with params validation on custom controller
      xcontext 'incorrect params' do
        let(:user_data) { invalid_params.to_json }

        it 'returns an unsuccessful response' do
          request
          expect(response).to_not be_successful
          expect(response.code).to eq '400'
          # TODO: improve reponse test coverage
          expect(body['errors'][0]['title']).to eq('Param not allowed')
        end
      end
    end
  end
end
