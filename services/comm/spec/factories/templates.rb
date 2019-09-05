# frozen_string_literal: true

FactoryBot.define do
  factory :template do
    campaign_entity_id { 1 }
    content { Faker::ChuckNorris.fact }
    status { 'N/a' }
  end
end
