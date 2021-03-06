# frozen_string_literal: true

class ChownRequestProcess < Ros::ActivityBase
  # - {id} ChownRequest id
  # - {from_ids} list of user ids to merge
  # - {to_id} Final user id to receive all the data

  # TODO: Needs improvement
  # - Ensure that user id is confirmed while all the other users are not
  # confirmed
  # - Which permissions should this require?
  # - For now, requesting user (identified via token), has to match the
  # id passed in the params

  step :create_chown_results

  private

  def create_chown_results(_ctx, id:, from_ids:, to_id:, **)
    from_ids.each do |from_id|
      %w[game instant-outcome voucher-service outcome].each do |service|
        ChownResult.create(chown_request_id: id, service_name: service,
                           from_id: from_id, to_id: to_id, status: 'pending')
      end
    end
  end
end
