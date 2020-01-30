# frozen_string_literal: true

FactoryBot.define do
  factory :whatsapp do
    sms_message_sid { SecureRandom.random_number(1_000_000) }
    sms_sid { SecureRandom.random_number(1_000_000) }
  end
end
