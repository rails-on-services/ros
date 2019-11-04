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
end
