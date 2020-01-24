# frozen_string_literal: true

class ChownRequest < Cognito::ApplicationRecord
  has_many :chown_results

  after_commit :publish_create_event, on: :create

  private

  def publish_create_event
    from_ids.each do |from_id|
      Ros::KarafkaPublisher.publish_to('chown_created', record: self, from_id: from_id)
    end
  end
end
