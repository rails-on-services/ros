# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tenant, type: :model do
  include_examples 'application record concern' do
    let(:tenant) { Tenant.first }
    subject { tenant }
  end

  it { is_expected.to validate_presence_of(:schema_name) }
  it { is_expected.to validate_uniqueness_of(:schema_name).ignoring_case_sensitivity }
end
