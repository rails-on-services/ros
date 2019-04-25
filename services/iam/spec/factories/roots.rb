# frozen_string_literal: true

FactoryBot.define do
  factory :root do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end
end
