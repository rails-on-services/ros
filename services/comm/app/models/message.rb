# frozen_string_literal: true

class Message < Comm::ApplicationRecord
  belongs_to :provider, optional: true
  belongs_to :owner, polymorphic: true, optional: true

  attr_accessor :recipient_id

  def self.sent_to(phone_number)
    search_number = phone_number.tr('^0-9', '%')
    where('messages.to LIKE ?', search_number)
  end

  validate :provider_channel, if: :provider

  def provider_channel
    return if channel.in? provider.channels

    errors.add(:channel, "must be one of: #{provider.channels.join(' ')}")
  end
end
