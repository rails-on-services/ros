# frozen_string_literal: true

class MergeRequest < Cognito::ApplicationRecord
  after_commit :enqueue_processing_job, on: :creat

  private

  def enqueue_processing_job
    MergeRequestProcessJob.perform_later(id: id)
  end
end
