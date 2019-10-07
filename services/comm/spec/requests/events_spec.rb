# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Events', type: :request do
  let(:tenant) { Tenant.first }
  # let(:tenant) { create(:tenant, schema_name: '222_222_222') }

  # Mocked results are 300% faster than non-mocked Basic Authentication
  # Mocked results are 10% faster than non-mocked Bearer Authentication
  let(:mock) { true }

  let(:url) { u('/events') }
  let(:subject) { tenant.switch { create(:event) } }

  context 'all' do
    include_context 'jsonapi requests'

    describe 'GET index' do
      context 'Unauthenticated user' do
        include_context 'unauthorized user'
        include_examples 'unauthenticated get'
      end

      context 'Authenticated user' do
        include_context 'authorized user'

        it 'returns correct payload' do
          mock_authentication if mock
          subject
          get url, headers: request_headers
          # TODO: move the tests from data.0 into get and show shared examples
          expect_json_types(data: :array)
          expect_json_types('data.0.attributes', :object) # Hash
          expect_json_keys('data.0.attributes', :name)
          expect_json_types('data.0.attributes', channel: :string)
          expect(subject.channel).to eq(get_response.channel)
        end
      end
    end

    describe 'POST create' do
      context 'unauthenticated user' do
        include_context 'unauthorized user'
        include_examples 'unauthenticated post'
      end

      context 'Authenticated user' do
        include_context 'authorized user'

        context 'correct params' do
          it 'returns the correct response and payload' do
            mock_authentication if mock
            # create an item in DB, duplicate its attributes and create a new one via API
            subject
            model_data = build(:event, provider_id: subject.provider_id, template_id: subject.template_id)
            post_data = jsonapi_data(model_data, true, [:status])
            post url, params: post_data, headers: request_headers
            expect(response).to be_created
            expect(model_data.channel).to eq(post_response.channel)
          end
        end

        context 'incorrect params' do
          it 'returns the correct response and payload' do
            mock_authentication if mock
            subject
            model_data = build(:event, provider_id: subject.provider_id, template_id: subject.template_id)
            post_data = jsonapi_data(model_data, false, [:status])
            post url, params: post_data, headers: request_headers
            expect(errors.size).to be_positive
            expect(response).to be_bad_request
            expect(error_response.title).to eq('Param not allowed')
          end
        end
      end
    end
  end
end
