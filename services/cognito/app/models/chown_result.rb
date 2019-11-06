# frozen_string_literal: true

class ChownResult < Cognito::ApplicationRecord
  belongs_to :chown_request

  after_commit :spawn_chown_jobs, on: :create

  private

  def spawn_chown_jobs
    Ros::ChownJob.set(queue: "#{service_name}_default")
                 .perform_later(from_id: from_id, to_id: to_id, chown_result_id: id)
  end
end
