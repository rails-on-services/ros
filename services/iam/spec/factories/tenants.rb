# frozen_string_literal: true

FactoryBot.modify do
  factory :tenant do
    properties { {} }
    schema_name { rand(100_000_000..999_999_999).to_s.scan(/.{3}/).join('_') }
    root

    initialize_with do
      new(attributes.merge(alias: Faker::Name.first_name))
    end
  end
end
