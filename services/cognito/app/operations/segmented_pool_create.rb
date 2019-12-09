# frozen_string_literal: true

class SegmentedPoolCreate < Ros::ActivityBase
  step :create_pool
  failed :pool_not_created, Output(:success) => End(:failure)

  def create_pool(ctx, **)
    ctx[:pool] = Pool.create(name: "temporary_pool_#{SecureRandom.hex}")
  end

  def pool_not_created(_ctx, errors:, **)
    errors.add(:pool, "Can't create temporary pool")
  end
end
