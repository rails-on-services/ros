# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Root Authentication', type: :request do
  context :create do
    let(:url) { '/roots/sign_in' }
    let(:root) { create(:root, email: 'test@email.com', password: '123456') }
    let(:valid_attributes) { { email: root.email, password: '123456' } }
    let(:invalid_attributes) { { email: root.email, password: 'fake' } }

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
      xit 'returns success status' do
        expect(response.status).to eq 200
      end
    end
  end
end
