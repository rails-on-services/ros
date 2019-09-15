
RSpec.configure do |rspec|
  # This config option will be enabled by default on RSpec 4,
  # but for reasons of backwards compatibility, you have to set it on RSpec 3.
  # It causes the host group and examples to inherit metadata from the shared context.
  rspec.shared_context_metadata_behavior = :apply_to_host_groups
end

  # def real_authentication
  #   Credential = Struct.new(:type, :access_key_id, :secret_access_key) do
  #     def to_s
  #       "#{type} #{access_key_id}:#{secret_access_key}"
  #     end
  #   end
  #   cr = Credential.new('Basic', 'AFJYOBPQKSJFQPKKHRHF', 'Zdl1fD957XvRlyRylFSr2McwZCxJHU36B4j5Ze2kqg8UPkcerz5YgQ')
  # end

  # Ros::Sdk::Credential.authorization 

# RSpec.shared_context 'fake authorized user' do
#   let(:tenant) { create(:tenant, schema_name: '222_222_222') }
#   let(:authorized_user) { build(:iam_user, :with_administrator_policy) }
#   let(:request_headers) do
#     {
#       'Authorization' => 'Basic invalid_key:invalid_secret',
#       # 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vaWFtLmxvY2FsaG9zdDozMDAwIiwic3ViIjoidXJuOndoaXN0bGVyOmlhbTo6MjIyMjIyMjIyOnVzZXIvQWRtaW5fMiIsInNjb3BlIjoiKiIsImF1ZCI6WyJodHRwOi8vbG9jYWxob3N0OjMwMDAiXSwiaWF0IjoxNTY4NTE2MjQzfQ.75fBdWTaYVEGwSSpht74Mfj-Lt4hIr9hdA7_HWJRmnI',
#       'Content-Type' => 'application/vnd.api+json'
#     }
#   end
# end

# List of http codes to symbols: response.methods.grep(/\?/)

RSpec.shared_context 'jsonapi requests' do
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

  def u(url); "#{Ros.dummy_mount_path}#{url}" end

  def mock_authentication
    # Return an instance of Ros::IAM::User to ApiTokenStrategy#authenticate!
    allow_any_instance_of(Ros::ApiTokenStrategy).to receive(:authenticate_basic).and_return(authorized_user)
    allow_any_instance_of(Ros::ApiTokenStrategy).to receive(:authenticate_bearer).and_return(authorized_user)
    # Return a valid schema name to TenantMiddleware#parse_schema_name
    allow_any_instance_of(Ros::TenantMiddleware).to receive(:tenant_name_from_basic).and_return(tenant.schema_name)
    allow_any_instance_of(Ros::TenantMiddleware).to receive(:tenant_name_from_bearer).and_return(tenant.schema_name)
  end
end

RSpec.shared_context 'authorized user' do
  let(:authorized_user) { build(:iam_user, :with_administrator_policy) }
  let(:iam_credential) { create(:iam_credential) }
  let(:request_headers) do
    {
      'Authorization' => iam_credential.str,
      # 'Authorization' => 'Bearer eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJodHRwOi8vaWFtLmxvY2FsaG9zdDozMDAwIiwic3ViIjoidXJuOndoaXN0bGVyOmlhbTo6MjIyMjIyMjIyOnVzZXIvQWRtaW5fMiIsInNjb3BlIjoiKiIsImF1ZCI6WyJodHRwOi8vbG9jYWxob3N0OjMwMDAiXSwiaWF0IjoxNTY4NTE2MjQzfQ.75fBdWTaYVEGwSSpht74Mfj-Lt4hIr9hdA7_HWJRmnI',
      'Content-Type' => 'application/vnd.api+json'
    }
  end
end

RSpec.shared_context 'unauthorized user' do
  let(:request_headers) do
    {
      # 'Authorization' => 'Basic invalid_key:invalid_secret',
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
