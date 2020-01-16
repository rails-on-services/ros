# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Messages', type: :request do
  include_context 'jsonapi requests'

  let(:tenant)   { Tenant.first }
  let(:mock)     { true }
  let(:base_url) { u('/messages') }
  let(:url)      { base_url }
  let(:provider) { create(:provider_aws) }

  describe 'GET index' do
    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated get'
    end

    context 'authenticated user' do
      include_context 'authorized user'

      let!(:models) { create_list :message, 3, to: '+6598765432' }
      let!(:message_to_user) { create_list :message, 2, to: '+6512345678' }
      let(:existing_user) { OpenStruct.new(id: 1, phone_number: message_to_user[0].to) }

      before do
        stubbed_resource(resource: Ros::Cognito::User, attributes: existing_user)
        get url, headers: request_headers
      end

      it 'returns an ok response status' do
        expect(response).to have_http_status(:ok)
        expect_json_sizes('data', 5)
      end

      describe 'when we filter by user id' do
        let(:url) { "#{base_url}?filter[user_id]=1" }

        describe 'when the user exists' do
          it 'returns all messages sent to that user' do
            expect(response).to have_http_status(:ok)
            expect_json_sizes('data', 2)
          end
        end

        describe 'when the user does not exist' do
          let(:existing_user) { [] }

          it 'it returns no messages at all' do
            expect(response).to have_http_status(:ok)
            expect_json_sizes('data', 0)
          end
        end
      end

      describe 'when we filter by phone number' do
        let(:url) { "#{base_url}?filter[to]=+6598765432" }

        it 'it returns only messages sent to the phone number' do
          expect(response).to have_http_status(:ok)
          expect_json_sizes('data', 3)
        end
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

      xcontext 'cognito user attempts to send message' do
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

        context 'when the payload does not include provider' do
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

          context 'with AWS provider setup' do
            let!(:aws_provider) { create :provider_aws }

            it 'should succeed' do
              post url, params: post_data, headers: request_headers
              expect(response).to be_successful
            end
          end

          context 'without AWS provider setup' do
            it 'should fail message sending' do
              expect(response).not_to be_successful
            end
          end
        end
      end
    end
  end
end
