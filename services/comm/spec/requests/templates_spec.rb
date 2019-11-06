# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Templates', type: :request do
  include_context 'jsonapi requests'

  let(:tenant) { Tenant.first }
  # let(:tenant) { create(:tenant, schema_name: '222_222_222') }

  # Mocked results are 300% faster than non-mocked Basic Authentication
  # Mocked results are 10% faster than non-mocked Bearer Authentication
  let(:mock) { true }

  let(:url) { u('/templates') }
  let(:template) { create(:template) }

  describe 'GET index' do
    context 'Unauthenticated user' do
      include_context 'unauthorized user'
      include_examples 'unauthenticated get'
    end

    context 'Authenticated user' do
      include_context 'authorized user'

      before do

        template
        get url, headers: request_headers
      end

      it 'returns correct payload' do
        # TODO: move the tests from data.0 into get and show shared examples
        expect_json_types(data: :array)
        expect_json_types('data.0.attributes', :object) # Hash
        expect_json_keys('data.0.attributes', :status)
        expect_json_types('data.0.attributes', content: :string)
        expect(template.content).to eq(get_response.content)
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

      let(:model_data) { build(:template, content: 'hello mr tambourine') }

      before do

        template
        post url, params: post_data, headers: request_headers
      end

      context 'correct params' do
        let(:post_data) { jsonapi_data(model_data, skip_attributes: [:status]) }

        it 'returns the correct response and payload' do
          expect(response).to be_created
          expect(model_data.content).to eq(post_response.content)
        end
      end

      context 'incorrect params' do
        let(:post_data) { jsonapi_data(model_data, extra_attributes: { invalid: :param }) }

        it 'returns the correct response and payload' do
          expect(errors.size).to be_positive
          expect(response).to be_bad_request
          expect(error_response.title).to eq('Param not allowed')
        end
      end
    end
  end
end
