FactoryBot.define do
  factory :event do
    send_at { 10.minutes.from_now }
    campaign
    provider
  end
end
