# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'templates requests', type: :request do
  include Warden::Test::Helpers

  def fake_authentication
    Warden.test_mode!
    login_as(authorized_user, scope: 'User')
    allow_any_instance_of(Ros::TenantMiddleware).to receive(:tenant_name_from_basic).and_return(tenant.schema_name)
    allow_any_instance_of(Ros::Sdk::Middleware).to receive(:call).and_return(OpenStruct.new(authenticated_headers: authenticated_headers))
    allow_any_instance_of(Ros::ApiTokenStrategy).to receive(:authenticate_basic).and_return(authorized_user)
    allow_any_instance_of(ApplicationController).to receive(:set_headers!)
  end

  let(:tenant) { FactoryBot.create(:tenant) }
  let(:authorized_user) do
    FactoryBot.create(:user, attached_policies: { 'AdministratorAccess' => 'true' },
                             jwt_payload: 'something')
  end
  let(:authenticated_headers) do
    {
      'Authorization' => 'Basic auth_token',
      'Content-Type' => 'application/vnd.api+json'
    }
  end

  let(:url) { '/templates' }
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
      let!(:template) { FactoryBot.create(:template, :within_schema, schema: tenant.schema_name) }

      before do
        other_tenant = FactoryBot.create(:tenant)
        FactoryBot.create(:template, :within_schema, schema: other_tenant.schema_name)
        fake_authentication
        get url, headers: authenticated_headers
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
      before do
        headers = { 'Content-Type' => 'application/vnd.api+json' }
        post url, params: '{}', headers: headers
      end

      it 'returns unauthenticated' do
        expect(response).to be_unauthorized
      end
    end

    context 'authenticated user' do
      before do
        fake_authentication
        post url, params: template_data, headers: authenticated_headers
      end

      context 'correct params' do
        let(:template_data) do
          '{
            "data": {
              "type": "templates",
              "attributes": {
                "content": "hello mr tambourine",
                "campaign_entity_id": "1"
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
        let(:template_data) do
          '{
            "data": {
              "type": "templates",
              "attributes": {
                "content": "hello mr tambourine",
                "campaign_entity_id": "1",
                "WRONG!!": "Cant do it"
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
