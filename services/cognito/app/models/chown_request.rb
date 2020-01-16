# frozen_string_literal: true

class ChownRequest < Cognito::ApplicationRecord
  has_many :chown_results

  after_commit :publish_create_event, on: :create

  private

  def publish_create_event
    publish_event('chown_created')
    # ChownRequestProcess.call(id: id, from_ids: from_ids, to_id: to_id)
  end
end
