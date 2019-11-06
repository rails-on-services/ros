# frozen_string_literal: true

FactoryBot.define do
  factory :chown_result do
    association :chown_request
  end
end
