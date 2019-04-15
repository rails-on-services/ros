# frozen_string_literal: true

class Event < Comm::ApplicationRecord
  belongs_to :campaign
  belongs_to :template
  belongs_to :provider
  # maybe target should be cognito_pool_id
  api_belongs_to :target, polymorphic: true
  # api_has_many :users, through: :target

  has_many :messages, as: :owner

  before_validation :set_defaults, on: :create

  validate :provider_channel

  after_save :queue_job, if: :published?

  # TODO: Decide if the target is always a Pool or not
  # TODO: Implement as api_has_many :users, through: :target
  def users
    Ros::Cognito::Pool.includes(:users).find(target_id).map(&:users).flatten
  end

  def set_defaults
    self.status ||= :pending
  end

  def provider_channel
    return unless provider
    return if channel.in? provider.class.services
    errors.add(:channel, "must be one of: #{provider.class.services.join(' ')}")
  end

  def published?; status.eql?('published') end

  def queue_job
    # EventJob.set(wait_until: send_at).perform_later(self, current_tenant.id)
    EventJob.perform_now(self, current_tenant.id)
  end
end
