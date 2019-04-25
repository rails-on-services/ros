# frozen_string_literal: true

FactoryBot.define do
  factory :campaign do
    owner_type { 'Test' }
    owner_id { 1 }
  end
end
