# frozen_string_literal: true

RSpec.configure do |rspec|
  # This config option will be enabled by default on RSpec 4,
  # but for reasons of backwards compatibility, you have to set it on RSpec 3.
  # It causes the host group and examples to inherit metadata from the shared context.
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

RSpec.shared_context 'jsonapi requests' do
  let(:mock) { false }
  let(:tenant) { Tenant.first }
  let(:body) { JSON.parse(response.body) }
  let(:data) { body['data'] }
  let(:attributes) { data[0]['attributes'] }

  let(:errors) { body['errors'] }
  let(:error_attributes) { errors[0] }
  let(:error_response) { OpenStruct.new(error_attributes) }

  let(:post_attributes) { data['attributes'] }
  let(:links) { body['links'] }
  let(:meta) { body['meta'] }

  let(:params) { {} }
  let(:get_response) { OpenStruct.new(attributes) }
  let(:post_response) { OpenStruct.new(post_attributes) }

  # This method smells of :reek:UncommunicativeMethodName
  def u(url)
    Rails.logger.debug 'Reconsider the use of this'
    "#{Ros.dummy_mount_path}#{url}"
  end

  # rubocop:disable Metrics/AbcSize
  def mock_authentication
    # Return an instance of Ros::IAM::User to ApiTokenStrategy#authenticate!
    allow_any_instance_of(Ros::ApiTokenStrategy).to receive(:authenticate_basic).and_return(authorized_user)
    allow_any_instance_of(Ros::ApiTokenStrategy).to receive(:authenticate_bearer).and_return(authorized_user)
    # Return a valid schema name to TenantMiddleware#parse_schema_name
    allow_any_instance_of(Ros::TenantMiddleware).to receive(:tenant_name_from_basic).and_return(tenant.schema_name)
    allow_any_instance_of(Ros::TenantMiddleware).to receive(:tenant_name_from_bearer).and_return(tenant.schema_name)
  end
  # rubocop:enable Metrics/AbcSize

  before do
    mock_authentication if mock
  end
end

RSpec.shared_context 'authorized user' do
  let(:authorized_user) { build(:iam_user, :with_administrator_policy) }
  let(:iam_credential) { create(:iam_credential) }
  let(:request_headers) do
    {
      'Authorization' => iam_credential.str,
      'Content-Type' => 'application/vnd.api+json'
    }
  end
end

RSpec.shared_context 'cognito user' do
  let(:authorized_user) { build(:iam_user, :with_administrator_policy) }
  let(:cognito_user_id) { 1 }
  let(:current_jwt) do
    jwt = Ros::Jwt.new(authorized_user.jwt_payload)
    jwt.add_claims('sub_cognito' => "urn:perx:cognito::222222222:user/#{cognito_user_id}")
    jwt.add_claims('act_cognito' => 'act_hello')
  end

  let(:request_headers) do
    {
      'Authorization' => "Bearer #{current_jwt.encode}",
      'Content-Type' => 'application/vnd.api+json'
    }
  end
end

RSpec.shared_context 'unauthorized user' do
  let(:authorized_user) { nil }
  let(:request_headers) do
    {
      'Authorization' => 'Bearer invalid_key:invalid_secret',
      'Content-Type' => 'application/vnd.api+json'
    }
  end
end

RSpec.shared_examples 'unauthenticated get' do
  it 'returns unauthorized' do
    get url
    expect(response).to be_unauthorized
  end
end

RSpec.shared_examples 'unauthenticated post' do
  it 'returns unauthorized' do
    post url, params: params, headers: request_headers

    expect(response).to be_unauthorized
  end
end

RSpec.shared_examples 'unauthenticated patch' do
  it 'returns unauthorized' do
    patch url, params: params, headers: request_headers
    expect(response).to be_unauthorized
  end
end

RSpec.shared_examples 'unauthenticated delete' do
  it 'returns unauthorized' do
    delete url, params: params, headers: request_headers
    expect(response).to be_unauthorized
  end
end
