# frozen_string_literal: true

require "rails_helper"

RSpec.describe 'User Authentication', type: :request do
  context :create do
    let(:url) { '/users/sign_in' }
    let(:tenant) { create(:tenant, platform_properties: { login_attribute_key: :phone }) }
    let!(:user) { tenant.switch { create(:user, phone: '123-123-123', password: '123456') } }
    let(:valid_attributes) { { login_attribute_value: '123-123-123', password: '123456' } }
    let(:invalid_attributes) { { login_attribute_value: '123-123-123', password: 'fake' } }

    before(:each) do
      allow_any_instance_of(Ros::TenantMiddleware).to receive(:tenant_name_from_basic).and_return(tenant.schema_name)
      post url, params: params, as: :json, headers: { 'Authorization' => 'Basic auth_token' }
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