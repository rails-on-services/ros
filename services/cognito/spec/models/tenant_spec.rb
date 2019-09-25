# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tenant, type: :model do
  include_examples 'application record concern' do
    let(:tenant) { Tenant.first }
    let(:subject) { tenant }
  end

  pending "add some examples to (or delete) #{__FILE__}"
end
