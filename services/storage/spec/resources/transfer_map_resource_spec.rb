# frozen_string_literal: true

require 'rails_helper'

RSpec.describe TransferMapResource, type: :resource do
  include_context 'jsonapi requests'
  let(:tenant) { Tenant.first }
  let(:subject) { create(:transfer_map) }

  let(:url) { '/transfer_maps' }
  let(:mock) { true }

  describe 'GET index' do
    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated get'
    end

    context 'Authenticated user' do
      include_context 'authorized user'

      before do
        mock_authentication if mock
        get url, headers: request_headers
      end

      it 'returns correct payload' do
        # TODO: move the tests from data.0 into get and show shared examples
        expect_json_types(data: :array)
        expect_json_types('data.0.attributes', :object) # Hash
        expect_json_keys('data.0.attributes', :name)
        expect_json_types('data.0.attributes', channel: :string)
        expect(subject.channel).to eq(get_response.channel)
      end
    end
  end
end
