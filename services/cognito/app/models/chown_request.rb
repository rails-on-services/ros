# frozen_string_literal: true

class ChownRequest < Cognito::ApplicationRecord
  has_many :chown_results

  after_commit :publish_create_event, on: :create

  private

  def publish_create_event
    from_ids.each do |from_id|
      puts "Producing event! #{{ record: self, from_id: from_id }.to_json}"
      WaterDrop::SyncProducer.call({ record: self, from_id: from_id }.to_json, topic: 'chown_created')
    end
    # ChownRequestProcess.call(id: id, from_ids: from_ids, to_id: to_id)
  end
end
