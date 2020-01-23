# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tenant, type: :model do
  include_examples 'application record concern' do
    let(:tenant) { Tenant.first }
    subject do
      # update schema to test uniqueness
      tenant.schema_name = '111_111_aaa'
      tenant.save(validate: false)
      tenant
    end
  end

  it { is_expected.to validate_presence_of(:schema_name) }
  it { is_expected.to validate_uniqueness_of(:schema_name) }
end
