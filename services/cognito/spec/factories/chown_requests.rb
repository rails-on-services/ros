# frozen_string_literal: true

FactoryBot.define do
  factory :chown_request do
    to_id { 1 }
    from_ids { [1] }
  end
end
