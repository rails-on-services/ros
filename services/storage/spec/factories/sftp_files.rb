# frozen_string_literal: true

FactoryBot.define do
  factory :sftp_file do
    name { Faker::Company.name }
    key { SecureRandom.uuid }
  end
end
