# frozen_string_literal: true

class SegmentedPoolCreate < Ros::ActivityBase
  step :create_pool
  failed :pool_not_created, Output(:success) => End(:failure)
  step :fetch_users
  failed :users_not_fetched, Output(:success) => End(:failure)
  step :add_users_to_pool

  def create_pool(ctx, **)
    ctx[:model] = Pool.create(name: "temporary_pool_#{SecureRandom.hex}")
  end

  def pool_not_created(_ctx, errors:, **)
    errors.add(:pool, "Can't create temporary pool")
  end

  def fetch_users(ctx, base_pool_id:, segments:, **)
    users = Pool.find(base_pool_id).users
    ctx[:users] = SegmentsApply.call(users: users, segments: segments).model
  end

  def users_not_fetched(_ctx, errors:, **)
    errors.add(:users, "Can't fetch users for pool")
  end

  def add_users_to_pool(_ctx, model:, users:, **)
    model.users << users
  end
end
