# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Org, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:branches) }
  end
end
