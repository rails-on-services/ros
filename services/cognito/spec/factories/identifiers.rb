# frozen_string_literal: true

FactoryBot.define do
  factory :identifier do
    name { 'MyString' }
    value { 'MyString' }
    user { nil }
    properties { '' }
  end
end
