require 'rails_helper'

RSpec.describe Campaign, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"

  it_behaves_like 'it belongs_to_resource', :owner
  it_behaves_like 'it belongs_to_resource', :cognito_endpoint
end
