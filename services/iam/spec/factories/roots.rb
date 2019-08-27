# frozen_string_literal: true

FactoryBot.define do
  factory :root, aliases: [:owner] do
    email { Faker::Internet.email }
    password { Faker::Internet.password }
  end
end
