# frozen_string_literal: true

FactoryBot.define do
  factory :column_map do
    association :transfer_map
    name { 'MyString' }
    user_name { 'MyString' }
  end
end
