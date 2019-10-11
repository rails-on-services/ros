# frozen_string_literal: true

class Event < Comm::ApplicationRecord
  # - includes/extends
  include AASM

  # - constants

  # - gems and related
  # TODO: we should have an extra status that informs us that all the messages
  # for this event have been scheduled
  aasm whiny_transitions: true, column: :status do
    state :pending, initial: true
    state :processing, :published

    event :process do
      transitions from: :pending, to: :processing
    end

    event :publish do
      transitions from: :processing, to: :published
    end
  end

  # - serialized attributes

  # - associations
  belongs_to :template
  belongs_to :provider
  # maybe target should be cognito_pool_id
  belongs_to_resource :target, polymorphic: true
  belongs_to_resource :owner, polymorphic: true

  has_many :messages, as: :owner
  # api_has_many :users, through: :target

  # - attr_accessible

  # - scopes

  # - class methods

  # - validations
  validate :provider_channel
  # NOTE: if there channel is not weblink, then target is mandatory
  validates :target, presence: true, if: -> { channel != 'weblink' }

  # - callbacks
  after_commit :queue_job, on: :create

  # TODO: Decide if the target is always a Pool or not
  # TODO: Implement as api_has_many :users, through: :target
  def users
    Ros::Cognito::Pool.includes(:users).find(target_id).map(&:users).flatten
  end

  # - other methods

  # - private
  private

  def provider_channel
    return unless provider

    channels = provider.class.services + ['weblink']
    return if channel.in? channels

    errors.add(:channel, "must be one of: #{channels.join(' ')}")
  end

  def queue_job
    EventJob.set(wait_until: send_at).perform_later(self, current_tenant.id)
  end
end
