# frozen_string_literal: true

FactoryBot.define do
  factory :pool do
    name { "#{Faker::Job.title}-#{SecureRandom.uuid}" }
    properties { '' }
  end
end
