# frozen_string_literal: true

class Message < Comm::ApplicationRecord
  belongs_to :provider
  belongs_to :owner, polymorphic: true

  validate :provider_channel, if: :provider

  def provider_channel
    return if channel.in? provider.class.services

    errors.add(:channel, "must be one of: #{provider.class.services.join(' ')}")
  end
end
