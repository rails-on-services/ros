# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Password management', type: :request do
  context :update do
    let(:url) { u('/users/password') }
    let(:tenant) { create(:tenant) }
    let(:password) { '123456' }
    let(:user) do
      create(:user, :within_schema,
             username: 'test_user',
             password: password,
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
    let(:password_reset_params) do
      { data: { attributes: {
        username: user.username,
        email: user.email,
        account_id: tenant.account_id
      } } }
    end
    let(:valid_params) do
      { data: { attributes: default_attributes } }
    end
    let(:invalid_params) do
      { data: { attributes: default_attributes.merge(password_confirmation: 'fef') } }
    end
    let(:mail_token) do
      Ros::Jwt.new(token: 'AAA',
                   account_id: tenant.account_id,
                   username: user.username).encode
    end
    let(:mail_params) do
      { data: { attributes: default_attributes.merge(token: mail_token) } }
    end

    before do
      post u('/users/sign_in'), params: {
        data: {
          attributes: {
            username: user.username,
            password: password,
            account_id: tenant.account_id
          }
        }
      }

      # we use fetch to ensure we don't have a nil @bearer_token
      @bearer_token = response.headers.fetch 'Authorization'
    end

    include_context 'jsonapi requests'

    context 'logging in' do
      # this is technically not needed as it tests the test implementation, but
      # it helps to throw an error if authentication hasn't happened for
      # whatever reason
      it 'should have a bearer token' do
        expect(@bearer_token).to_not be_nil
      end

      it 'should allow login' do
        expect(response).to be_successful
      end
    end

    context 'updating password' do
      # the authorized_user we get from the shared context is an IAM user, not a
      # regular user
      let(:authorized_user) { user }
      let(:request_headers) do
        {
          'Authorization' => @bearer_token,
          'Content-Type' => 'application/vnd.api+json'
        }
      end

      context 'with invalid password_confirmation' do
        let(:params) { invalid_params }

        it 'returns error' do
          put url, params: params, headers: request_headers, as: :json
          expect(response).to be_bad_request
        end
      end

      context 'with valid password_confirmation' do
        let(:params) { mail_params }

        it 'returns success status' do
          allow(User).to receive(:reset_password_by_token)
            .with(reset_password_token: 'AAA',
                  password: default_attributes[:password],
                  password_confirmation: default_attributes[:password_confirmation]).and_return(user)

          put url, params: params, headers: request_headers, as: :json
          expect(response).to be_successful
        end
      end
    end

    context 'triggering password recovery email' do
      let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }

      before do
        post url, params: params, headers: headers, as: :json
      end

      context 'when no user is specified' do
        let(:params) { { data: { attributes: { username: nil, account_id: tenant.account_id } } } }

        it 'should fail' do
          expect(response).to_not be_successful
        end
      end

      context 'when no tenant is specified' do
        let(:params) { { data: { attributes: { username: user.username, account_id: nil } } } }

        it 'should fail when no tenant is specified' do
          expect(response).to_not be_successful
        end
      end

      context 'with the right params and no auth headers' do
        let(:params) { password_reset_params }

        it 'should allow performing a password reset/recovery' do
          expect(response).to be_successful
        end
      end
    end
  end
end
