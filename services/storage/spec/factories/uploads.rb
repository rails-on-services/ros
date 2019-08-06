# frozen_string_literal: true

FactoryBot.define do
  factory :upload do
    name { 'MyString' }
    etag { 'MyString' }
    size { 1 }
    transfer_map_id { 1 }
  end
end
