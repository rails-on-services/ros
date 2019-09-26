# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Files requests', type: :request do

  describe 'POST /files' do
    let(:url) { '/files' }
    let(:tenant) { Tenant.first }
    let(:file) { nil }
    let(:file_params) { { file: file } }

    let(:mock) { true }

    include_context 'jsonapi requests'

    context 'Authorized user' do
      include_context 'authorized user'

      before do
        allow_any_instance_of(ActiveStorage::Blob).to receive(:service_url).and_return('mock_url')
        mock_authentication
        post url, headers: request_headers, params: file_params
      end

      context 'Image upload' do
        let(:file) { fixture_file_upload(Rails.root.join('../', 'fixtures', 'image_fixture.jpg'), 'image/png') }

        it 'returns successfull response' do
          expect(response).to be_successful
        end

        it 'returns image path' do
          expect(json_body[:data][0][:attributes][:urn]).to start_with("#{tenant.schema_name}/image")
        end
      end

      context 'Document upload' do
        let(:file) { fixture_file_upload(Rails.root.join('../', 'fixtures', 'csv_fixture.csv'), 'text/csv') }

        it 'returns successfull response' do
          expect(response).to be_successful
        end

        it 'returns document path' do
          expect(json_body[:data][0][:attributes][:urn]).to start_with("#{tenant.schema_name}/document")
        end
      end
    end
  end
end