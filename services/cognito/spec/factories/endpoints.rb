# frozen_string_literal: true

FactoryBot.define do
  factory :endpoint do
    url { 'http://localhost:3000/test' }
    target_type { 'Perx::Survey::Campaign' }
    target_id { 1 }
    properties { {}  }
  end
end
