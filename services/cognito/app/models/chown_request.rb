# frozen_string_literal: true

class ChownRequest < Cognito::ApplicationRecord
  has_many :chown_results

  after_commit :create_chown_results, on: :create

  private

  def create_chown_results
    ChownRequestProcess.call(id: id, from_ids: from_ids, to_id: to_id)
  end
end
