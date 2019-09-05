# frozen_string_literal: true

FactoryBot.define do
  factory :user, class: OpenStruct do
    username { Faker::Internet.username }
    attached_policies { {} }
  end
end
