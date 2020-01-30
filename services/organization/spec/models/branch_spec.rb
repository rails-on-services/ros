# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Branch, type: :model do
  include_examples 'application record concern'

  describe 'associations' do
    it { is_expected.to belong_to(:org) }
  end
end
