# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Password management', type: :request do
  context :update do
    let(:mock) { false }
    let(:url) { '/users/password' }
    let(:tenant) { create(:tenant) }
    let(:user) do
      create(:user, :within_schema,
             username: 'test_user',
             password: '123456',
             email: 'foo@perx.test',
             schema: tenant.schema_name)
    end
    let(:default_attributes) do
      {
        username: user.username,
        email: user.email,
        password: 'abc',
        password_confirmation: 'abc',
        account_id: tenant.account_id
      }
    end
    let(:valid_params)   { { data: { attributes: default_attributes } } }
    let(:invalid_params) { { data: { attributes: default_attributes.merge(password_confirmation: 'fef') } } }

    context 'resetting password' do
      include_context 'jsonapi requests'
      include_context 'authorized user'
      # the authorized_user we get from the shared context is an IAM user, not a
      # regular user
      let(:authorized_user) { user }

      context 'with invalid password_confirmation' do
        let(:params) { invalid_params }

        it 'returns error' do
          mock_authentication if mock
          put url, params: params, headers: request_headers, as: :json
          expect(response.status).to eq 400
        end
      end

      context 'with valid password_confirmation' do
        let(:params) { valid_params }

        it 'returns success status', wip: true do
          mock_authentication if mock
          put url, params: params, headers: request_headers, as: :json
          expect(response.status).to eq 200
        end
      end
    end
  end
end
