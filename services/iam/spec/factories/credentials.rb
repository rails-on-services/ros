# frozen_string_literal: true

FactoryBot.define do
  factory :credential do
    owner { create(:user) }
  end
end
