# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: OpenStruct do
    phone_number { Faker::PhoneNumber.phone_number }
    username { Faker::Internet.username }
    attached_policies { {} }
  end
end
