# frozen_string_literal: true

class ChownRequest < Cognito::ApplicationRecord
  after_commit :spawn_chown_jobs, on: :create

  private

  def spawn_chown_jobs
    ChownRequestProcess.call(id: id, from_ids: from_ids, to_id: to_ids)
  end
end
