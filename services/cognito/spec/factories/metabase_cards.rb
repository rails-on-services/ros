FactoryBot.define do
  factory :metabase_card do
    card_id         { rand(1..1000) }
    uniq_identifier { Faker::Internet.username }
  end
end
