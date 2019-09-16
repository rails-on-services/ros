# frozen_string_literal: true

FactoryBot.define do
  factory :branch do
    name { 'MyString' }
    properties { {} }
    org
  end
end
