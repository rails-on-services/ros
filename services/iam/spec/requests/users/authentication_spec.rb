# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Authentication', type: :request do
  include_context 'jsonapi requests'

  context :create do
    let(:url) { service_url('/users/sign_in') }
    let(:tenant) { create(:tenant) }
    let(:user) { create(:user, :within_schema, username: 'test_user', password: '123456', schema: tenant.schema_name) }
    let(:valid_attributes) { { username: user.username, password: '123456' } }
    let(:invalid_attributes) { { username: user.username, password: 'fake', account_id: tenant.account_id } }

    before(:each) do
      post url, params: params, as: :json
    end

    context 'Invalid request' do
      context 'with invalid credentials' do
        let(:params) { { data: { attributes: invalid_attributes } } }
        it 'returns unauthorized status' do
          expect(response).to be_unauthorized
        end
      end

      context 'without :account_id or :alias' do
        let(:params) { { data: { attributes: valid_attributes } } }
        it 'returns unauthorized status' do
          expect(response).to be_unauthorized
        end
      end

      context 'unconfirmed user with valid request' do
        let(:params) { { data: { attributes: valid_attributes.merge(account_id: tenant.account_id) } } }
        let(:user) do
          create(
            :user,
            :within_schema,
            username: 'test_user',
            password: '123456',
            schema: tenant.schema_name,
            confirmed_at: nil
          )
        end

        it 'returns unauthorized status' do
          expect(response).to be_unauthorized
        end
      end
    end

    context 'Valid request' do
      context 'with :account_id' do
        let(:params) { { data: { attributes: valid_attributes.merge(account_id: tenant.account_id) } } }

        it 'returns success status' do
          expect(response).to be_successful
        end

        it 'sets the authorization header with the token for the user' do
          expect(response.headers['Authorization']).to_not be_nil
        end
      end

      context 'with :account_alias' do
        let(:params) { { data: { attributes: valid_attributes.merge(account_id: tenant.alias) } } }
        it 'returns success status' do
          expect(response).to be_successful
        end

        it 'sets the authorization header with the token for the user' do
          expect(response.headers['Authorization']).to_not be_nil
        end
      end
    end
  end
end
