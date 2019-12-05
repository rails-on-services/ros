# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Messages', type: :request do
  include_context 'jsonapi requests'

  let(:tenant)   { Tenant.first }
  let(:mock)     { true }
  let(:url)      { u('/messages') }
  let(:provider) { create(:provider_aws) }
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

  before do
    mock_authentication if mock
    post url, params: post_data, headers: request_headers
  end

  describe 'POST create' do
    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated get'
    end

    context 'Authenticated user' do
      include_context 'cognito user'

      context 'cognito user attempts to send message' do
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
          it 'should fail message sending' do
            expect(response).not_to be_successful
          end
        end
      end
    end
  end
end
