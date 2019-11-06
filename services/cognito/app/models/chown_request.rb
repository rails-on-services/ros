# frozen_string_literal: true

class ChownRequest < Cognito::ApplicationRecord
  after_commit :enqueue_processing_job, on: :create

  private

  def enqueue_processing_job
    ChownRequestProcessJob.perform_later(id: id)
  end
end
