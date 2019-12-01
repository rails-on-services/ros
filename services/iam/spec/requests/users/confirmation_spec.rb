# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Account confirmation', type: :request do
  context :update do
    let(:url) { u('/users/confirmation') }
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
        account_id: tenant.account_id
      }
    end
    let(:valid_params) { { data: { attributes: default_attributes } } }
    let(:mail_token) do
      Ros::Jwt.new(token: 'AAA',
                   account_id: tenant.account_id,
                   username: user.username).encode
    end
    let(:mail_params) do
      { data: { attributes: default_attributes.merge(token: mail_token) } }
    end
    let(:headers) { { 'Content-Type' => 'application/vnd.api+json' } }

    include_context 'jsonapi requests'

    context 'should trigger confirmation email' do
      before do
        post url, params: params, headers: headers, as: :json
      end

      context 'when no tenant is specified' do
        let(:params) { { data: { attributes: { username: user.username, account_id: nil } } } }

        it 'should fail' do
          expect(response).to_not be_successful
        end
      end

      context 'when no used is specified' do
        let(:params) { { data: { attributes: { username: nil, account_id: tenant.account_id } } } }

        it 'should fail when no user is specified' do
          expect(response).to_not be_successful
        end
      end

      context 'with the right params and no auth headers' do
        let(:params) { valid_params }

        it 'should allow performing an account confirmation without authentication' do
          expect(response).to be_successful
        end
      end
    end

    context 'confirming account from email' do
      let(:params) { mail_params }

      it 'should confirm the user' do
        allow(User).to receive(:confirm_by_token)
          .with('AAA').and_return(user)

        get url, params: params, headers: headers
        expect(response).to be_successful
      end
    end
  end
end
