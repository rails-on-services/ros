# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'events requests', type: :request do
  let(:url) { '/events' }
  let(:body) { JSON.parse(response.body) }

  describe 'GET index' do
    context 'unauthenticated user' do
      before do
        get url
      end

      it 'returns unauthenticated' do
        expect(response).to be_unauthorized
      end
    end

    context 'authenticated user' do
      let(:tenant) { FactoryBot.create(:tenant) }
      let(:authorized_user) do
        FactoryBot.create(:user, attached_policies: { 'AdministratorAccess' => 'true' },
                                 jwt_payload: 'something')
      end
      let(:request_headers) do
        {
          'Authorization' => 'Basic auth_token',
          'Content-Type' => 'application/vnd.api+json'
        }
      end
      let!(:event) { FactoryBot.create(:event, :within_schema, schema: tenant.schema_name) }

      before do
        other_tenant = FactoryBot.create(:tenant)
        FactoryBot.create(:event, :within_schema, schema: other_tenant.schema_name)
        Warden.test_mode!
        login_as(authorized_user, scope: 'User')
        allow_any_instance_of(Ros::TenantMiddleware).to receive(:tenant_name_from_basic).and_return(tenant.schema_name)
        allow_any_instance_of(Ros::Sdk::Middleware).to receive(:call).and_return(OpenStruct.new(request_headers: request_headers))
        allow_any_instance_of(Ros::ApiTokenStrategy).to receive(:authenticate_basic).and_return(authorized_user)
        allow_any_instance_of(ApplicationController).to receive(:set_headers!)
        get url, headers: request_headers
      end

      it 'returns a successful response' do
        expect(response).to be_successful
        # TODO: improve reponse test coverage
        expect(body['data']).to_not be_nil
      end
    end
  end

  xdescribe 'POST create' do
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
        tenant = FactoryBot.create :tenant
        cr = {}
        tenant.switch do
          user = FactoryBot.create(:user, :administrator_access)
          login(user)
          cr = user.credentials.create
        end
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

        it 'returns a successful response' do
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

        it 'returns a successful response' do
          expect(response).to_not be_successful
          expect(response.code).to eq '400'
          # TODO: improve reponse test coverage
          expect(body['errors'][0]['title']).to eq('Param not allowed')
        end
      end
    end
  end
end
