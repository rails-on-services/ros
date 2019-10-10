# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Password management', type: :request do
  context :update do
    let(:mock) { true }
    let(:url) { '/users/password' }
    let(:tenant) { create(:tenant) }
    let(:user) { create(:user, :within_schema, username: 'test_user', password: '123456', schema: tenant.schema_name) }
    let(:default_attributes) {
      {
        username: user.username,
        password: 'abc',
        password_confirmation: 'abc',
        account_id: tenant.account_id
      } }
    let(:valid_params)   { { data: { attributes: default_attributes }}}
    let(:invalid_params) { { data: { attributes: default_attributes.merge(password_confirmation: 'fef') }}}

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

        it 'returns success status' do
          mock_authentication if mock
          put url, params: params, headers: request_headers, as: :json
          expect(response.status).to eq 200
        end
      end
    end
  end
end
