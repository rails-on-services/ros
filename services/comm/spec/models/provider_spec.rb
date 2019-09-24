# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Provider, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end

RSpec.describe Providers::Aws, type: :model do
  include_examples 'application record concern' do
    let(:tenant) { Tenant.first }
    let(:factory_name) { :provider_aws }
    let!(:subject) { create(factory_name) }
  end

  pending "add some examples to (or delete) #{__FILE__}"
end

RSpec.describe Providers::Twilio, type: :model do
  include_examples 'application record concern' do
    let(:tenant) { Tenant.first }
    let(:factory_name) { :provider_twilio }
    let!(:subject) { create(factory_name) }
  end

  pending "add some examples to (or delete) #{__FILE__}"
end
