# frozen_string_literal: true

FactoryBot.define do
  factory :identifier do
    name { Faker::Job.title }
    value { Faker::Job.title }
    user
    properties { {} }
  end
end
