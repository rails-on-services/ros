# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Messages', type: :request do
  include_context 'jsonapi requests'

  let(:tenant)   { Tenant.first }
  let(:mock)     { true }
  let(:url)      { u('/messages') }
  let(:provider) { create(:provider_aws) }

  describe 'GET index' do
    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated get'
    end

    context 'authenticated user' do
      include_context 'authorized user'

      let(:models_count) { rand(1..5) }
      let!(:models) { create_list :message, models_count }

      before do
        get url, headers: request_headers
      end

      it 'returns returns an ok response status' do
        expect(response).to have_http_status(:ok)
        expect_json_sizes('data', models_count)
      end
    end
  end

  describe 'POST create' do
    let(:post_data) do
      {
        data: {
          attributes: {
            body: 'HELLO DEAR HELLO',
            to: '+6587173612',
            from: 'PerxTest',
            provider_id: provider.id,
            channel: 'sms'
          }
        }
      }.to_json
    end

    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated get'
    end

    context 'Authenticated user' do
      before do
        post url, params: post_data, headers: request_headers
      end

      context 'cognito user attempts to send message' do
        let(:cognito_user_id) { 1 }

        include_context 'cognito user'

        it 'should not allow message to be sent' do
          expect(response).not_to be_successful
        end
      end

      context 'authorized user attempts to send message' do
        include_context 'authorized user'

        context 'when the payload is valid' do
          it 'should send message successfully' do
            expect(response).to be_successful
          end
        end

        context 'when the payload is invalid' do
          let(:post_data) do
            {
              data: {
                attributes: {
                  body: 'HELLO DEAR HELLO',
                  to: '+6587173612',
                  from: 'PerxTest',
                  provider_id: nil,
                  channel: 'sms'
                }
              }
            }.to_json
          end

          it 'should fail message sending' do
            expect(response).not_to be_successful
          end
        end
      end
    end
  end
end
