# frozen_string_literal: true

class SegmentedPoolCreate < Ros::ActivityBase
  step :find_base_pool
  failed :base_pool_not_found, Output(:success) => End(:failure)
  step :fetch_users
  failed :users_not_fetched, Output(:success) => End(:failure)
  step :create_pool
  failed :pool_not_created, Output(:success) => End(:failure)
  step :add_users_to_pool

  def find_base_pool(ctx, base_pool_id:, **)
    ctx[:base_pool] = Pool.find(base_pool_id)
  end

  def base_pool_not_found(_ctx, errors:, base_pool_id:, **)
    errors.add(:base_pool, "Can't find base pool with id: #{base_pool_id}")
  end

  def fetch_users(ctx, base_pool:, segments:, **)
    ctx[:users] = SegmentsApply.call(users: base_pool.users, segments: segments).model
    # NOTE: don't create an empty pool
    ctx[:users].any?
  end

  def users_not_fetched(_ctx, errors:, **)
    errors.add(:users, "Can't fetch users for pool")
  end

  def create_pool(ctx, **)
    ctx[:model] = Pool.create(name: "temporary_pool_#{SecureRandom.hex}")
  end

  def pool_not_created(_ctx, errors:, **)
    errors.add(:pool, "Can't create temporary pool")
  end

  def add_users_to_pool(_ctx, model:, users:, **)
    model.users << users
  end
end
