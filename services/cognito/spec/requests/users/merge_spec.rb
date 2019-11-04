# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'users merge requests', type: :request do
  include_context 'jsonapi requests'

  let(:mock) { true }
  let(:url) { "/users/#{user_id}/merge" }
  let(:params) { { merge_ids: [anonymous_user_id] } }
  let(:user_id) { 1 }
  let(:anonymous_user_id) { 2 }

  describe 'POST merge users' do
    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated post'
    end

    context 'authenticated user' do
      include_context 'cognito user'

      let(:cognito_user_id) { 1 }

      before do
        post url, headers: request_headers, params: params
      end

      it 'returns a successful response' do
        binding.pry

        expect(response).to be_successful
        # TODO: improve reponse test coverage
        # expect(body['data']).to_not be_nil
      end
    end
  end
end
