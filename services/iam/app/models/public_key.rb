# frozen_string_literal: true

class PublicKey < Ros::Iam::ApplicationRecord
  belongs_to :user

  after_commit :enqueue

  def enqueue
    Ros::PlatformEventProcessJob.set(queue: job_queue).perform_later(job_payload.to_json)
  end

  def job_queue; 'storage_default' end

  def job_payload
    { operation: 'IamPublicKeyProcess', id: user.id }
  end
end
