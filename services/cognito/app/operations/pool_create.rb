# frozen_string_literal: true

class PoolCreate < Ros::ActivityBase
  step :check_permission
  failed :not_permitted, Output(:success) => End(:failure)
  step :should_be_segmented?, Output(:failure) => Id(:create_regular_pool), Output(:success) => Id(:find_base_pool)
  step :create_regular_pool, Output(:success) => End(:success), Output(:failure) => End(:failure)

  step :find_base_pool
  failed :base_pool_not_found, Output(:success) => End(:failure)
  step :apply_segment
  failed :fail_to_apply_segment, Output(:success) => End(:failure)
  step :create_pool
  failed :pool_not_created, Output(:success) => End(:failure)
  step :add_users_to_pool

  def check_permission(_ctx, user:, **)
    PoolPolicy.new(user, Pool.new).create?
  end

  def not_permitted(_ctx, errors:, **)
    errors.add(:user, 'not permitted to create a pool')
  end

  def should_be_segmented?(_ctx, params:, **)
    params.key?(:base_pool_id) && params.key?(:segments)
  end

  def create_regular_pool(ctx, params:, **)
    ctx[:model] = Pool.create(params)
  end

  def find_base_pool(ctx, params:, **)
    ctx[:base_pool] = Pool.find(params[:base_pool_id])
  end

  def base_pool_not_found(_ctx, errors:, params:, **)
    errors.add(:base_pool, "Can't find base pool with id: #{params[:base_pool_id]}")
  end

  def apply_segment(ctx, base_pool:, params:, **)
    segment_result = SegmentsApply.call(users: base_pool.users, segments: params[:segments])
    return false unless segment_result.success?

    ctx[:users] = segment_result.model
  end

  def fail_to_apply_segment(_ctx, errors:, **)
    errors.add(:users, 'Failed to apply segment')
  end

  def create_pool(ctx, **)
    ctx[:model] = Pool.create(name: "temporary_pool_#{SecureRandom.hex}", system_generated: true)
  end

  def pool_not_created(_ctx, errors:, **)
    errors.add(:pool, "Can't create temporary pool")
  end

  def add_users_to_pool(_ctx, model:, users:, **)
    return true if users.empty?

    model.users << users
  end
end
