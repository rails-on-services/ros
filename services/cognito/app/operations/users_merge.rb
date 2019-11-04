# frozen_string_literal: true

class UsersMerge < Ros::ActivityBase
  # TODO: recieve set of params that are accepted for merging:
  # - {user id} to keep
  # - {list of user ids} to merge
  # - Ensure that user id is confirmed while all the other users are not
  # confirmed
  # - Which permissions should this require?
  # - For now, requesting user (identified via token), has to match the
  # id passed in the params
  step :validate_user_permissions
  fail :invalid_permissions
  step :enqueue_ownership_change

  private

  def validate_user_permissions(_ctx, id:, current_user:, **)
    id.to_i == current_user.cognito_user_id.to_i
  end

  def invalid_permissions(_ctx, errors:, **)
    errors.add(:user_id, "does not match the request's user")
  end

  # TODO: This should be an async process where this publishes the merging action
  # and each service knows its internals how to proceed with the merging
  # e.g. queue.publish(action: 'merge', params: { cognito_uid: 10, merge_ids: [] })
  def find_user_transactions(ctx, id:, merge_params:, **)
    %w[survey game instant-outcome voucher outcome].each do |service|
      Ros::ChownJob.set(queue: "#{service}_default").perform_later(id: id, merge_params: merge_params)
    end
  end
end
