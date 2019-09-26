# frozen_string_literal: true

FactoryBot.define do
  factory :transfer_map do
    name { 'MyString' }
    description { 'MyString' }
    service { 'cognito' }
    target { 'user' }
  end
end
