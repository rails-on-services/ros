# frozen_string_literal: true

class Event < Comm::ApplicationRecord
  # - includes/extends
  include AASM

  # - constants

  # - gems and related
  aasm whiny_transitions: true, column: :status do
    state :draft, initial: true
    state :scheduled, :active, :paused, :ended
  end

  # - serialized attributes

  # - associations
  belongs_to :template
  belongs_to :provider
  # maybe target should be cognito_pool_id
  belongs_to_resource :target, polymorphic: true

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
  before_validation :set_defaults, on: :create
  after_save :queue_job, if: :published?

  # - instance methods
  # TODO: replace this with enum
  def published?; status.eql?('published') end

  # TODO: Decide if the target is always a Pool or not
  # TODO: Implement as api_has_many :users, through: :target
  def users
    Ros::Cognito::Pool.includes(:users).find(target_id).map(&:users).flatten
  end

  # - other methods

  # - private
  private

  def set_defaults
    self.status ||= :pending
  end

  def provider_channel
    return unless provider

    channels = provider.class.services + ['weblink']
    return if channel.in? channels

    errors.add(:channel, "must be one of: #{channels.join(' ')}")
  end

  def queue_job
    EventJob.set(wait_until: send_at).perform_later(self, current_tenant.id)
    # EventJob.perform_now(self, current_tenant.id)
  end
end
