# frozen_string_literal: true

class Message < Comm::ApplicationRecord
  belongs_to :provider
  belongs_to :owner, polymorphic: true
  # api_belongs_to :cognito_user_id, class_name: 'Ros::Cognito::User'

  validate :provider_channel

  after_create :send_message

  def provider_channel
    return if channel.in? provider.class.services

    errors.add(:channel, "must be one of: #{provider.class.services.join(' ')}")
  end

  def send_message
    MessageJob.perform_later(self, current_tenant.id)
  end
end
