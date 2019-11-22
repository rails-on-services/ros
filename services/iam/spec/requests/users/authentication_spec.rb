# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User Authentication', type: :request do
  include_context 'jsonapi requests'

  context :create do
    let(:url) { u('/users/sign_in') }
    let(:tenant) { create(:tenant) }
    let(:user) { create(:user, :within_schema, username: 'test_user', password: '123456', schema: tenant.schema_name) }
    let(:valid_attributes) { { username: user.username, password: '123456' } }
    let(:invalid_attributes) { { username: user.username, password: 'fake', account_id: tenant.account_id } }

    before(:each) do
      post url, params: params, as: :json
    end

    context 'with invalid credentials' do
      let(:params) { { data: { attributes: invalid_attributes } } }
      it 'returns unauthorized status' do
        expect(response).to be_unauthorized
      end
    end

    context 'without :account_id or :alias' do
      let(:params) { { data: { attributes: valid_attributes } } }
      it 'returns error status' do
        expect(response).to be_unauthorized
      end
    end

    context 'with :account_id' do
      let(:params) { { data: { attributes: valid_attributes.merge(account_id: tenant.account_id) } } }
      it 'returns success status' do
        expect(response).to be_successful
      end

      xit 'sets the authorization header with the token for the user' do
      end
    end

    context 'with :account_alias' do
      let(:params) { { data: { attributes: valid_attributes.merge(account_id: tenant.alias) } } }
      it 'returns success status' do
        expect(response).to be_successful
      end

      xit 'sets the authorization header with the token for the user' do
      end
    end
  end
end
