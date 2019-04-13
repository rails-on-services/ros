FactoryBot.define do
  factory :endpoint do
    url { 'http://localhost:3000/test' }
    tenant
    target_type { 'Survey::Campaign' }
    target_id { 1 }
    properties { '' }
  end
end
