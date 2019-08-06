# frozen_string_literal: true

FactoryBot.define do
  factory :column_map do
    transfer_map { nil }
    name { 'MyString' }
    user_name { 'MyString' }
  end
end
