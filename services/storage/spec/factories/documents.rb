# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    header { 'MyString' }
    transfer_map_id { 1 }
  end
end
