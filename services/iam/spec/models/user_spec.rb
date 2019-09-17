# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    create :user
  end

  describe 'validations' do
    it { is_expected.to validate_uniqueness_of(:username) }
    it { is_expected.to validate_presence_of(:username) }
  end
end
