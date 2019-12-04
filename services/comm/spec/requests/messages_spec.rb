# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Messages', type: :request do
  include_context 'jsonapi requests'

  let(:tenant) { Tenant.first }
  let(:mock) { true }
  let(:url) { u('/messages') }

  describe 'POST create' do
    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated get'
    end

    context 'Authenticated user' do
      include_context 'authorized user'

      context 'cognito user attempts to send message' do
        it 'should not allow message to be sent' do
        end
      end

      context 'non cognito user attempts to send message' do
        context 'when the payload is valid' do
          it 'should send message successfully' do
          end
        end

        context 'when the payload is invalid' do
          it 'should fail message sending' do
          end
        end
      end
    end
  end
end
