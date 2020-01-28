# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Tenant, type: :model do
  it { is_expected.to validate_uniqueness_of(:root_id) }
end
