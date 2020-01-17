# frozen_string_literal: true

class ChownRequest < Cognito::ApplicationRecord
  has_many :chown_results

  after_commit :publish_create_event, on: :create

  private

  def publish_create_event
    from_ids.each do |from_id|
      WaterDrop::SyncProducer.call({ record: to_json, from_id: from_id }, topic: 'chown_created')
    end
    # ChownRequestProcess.call(id: id, from_ids: from_ids, to_id: to_id)
  end
end
