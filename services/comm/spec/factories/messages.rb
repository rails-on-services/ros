# frozen_string_literal: true

FactoryBot.define do
  factory :message do
    provider
    from { Faker::PhoneNumber.cell_phone }
    to { Faker::PhoneNumber.cell_phone }
    body { Faker::Lorem.paragraph }
  end
end
