# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'User changing passwords', type: :request do
  context :update do
    let(:url) { '/users/update' }
    let(:tenant) { create(:tenant) }
    let(:user) { create(:user, :within_schema, username: 'test_user', password: '123456', schema: tenant.schema_name) }
    let(:valid_attributes) { { username: user.username, password: '123456' } }
    let(:invalid_attributes) { { username: user.username, password: 'fake', account_id: tenant.account_id } }


    before(:each) do
      put url, params: params, as: :json
    end

    context 'resetting password' do
      let(:params) { { data: { attributes: valid_attributes.merge(account_id: tenant.alias) } } }
      it 'returns success status' do
        expect(response.status).to eq 300
      end
    end
  end
end
