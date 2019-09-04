# frozen_string_literal: true

require "rails_helper"

RSpec.describe 'User Authentication', type: :request do
  context :create do
    let(:url) { '/users/sign_in' }
    let(:tenant) { create(:tenant) }
    let(:user) { create(:user, :within_schema, username: 'test_user', password: '123456', schema: tenant.schema_name) }
    let(:valid_attributes) { { username: user.username, password: '123456', tenant_id: tenant.id } }
    let(:invalid_attributes) { { username: user.username, password: 'fake', tenant_id: tenant.id } }

    before(:each) do
      post url, params: params, as: :json
    end

    context 'with invalid credentials' do
      let(:params) { { data: { attributes: invalid_attributes } } }
      it 'returns unauthorized status' do
        expect(response.status).to eq 401
      end
    end

    context 'with valid credentials' do
      let(:params) { { data: { attributes: valid_attributes } } }
      it 'returns success status' do
        expect(response.status).to eq 200
      end
    end
  end
end