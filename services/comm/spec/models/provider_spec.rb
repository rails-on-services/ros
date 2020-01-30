# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Provider, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

RSpec.describe Providers::Aws, type: :model do
  include_examples 'application record concern' do
    let(:factory_name) { :provider_aws }
  end

  pending "add some examples to (or delete) #{__FILE__}"
end

RSpec.describe Providers::Twilio, type: :model do
  include_examples 'application record concern' do
    let(:factory_name) { :provider_twilio }
  end

  pending "add some examples to (or delete) #{__FILE__}"
end
