# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    primary_identifier { SecureRandom.uuid }
    properties { '' }

    transient do
      with_age { nil }
    end

    before(:create) do |user, evaluator|
      user.birthday = Time.zone.today - evaluator.with_age.years unless evaluator.with_age.nil?
    end
  end
end
