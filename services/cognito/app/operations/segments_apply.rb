# frozen_string_literal: true

class SegmentsApply < Ros::ActivityBase
  step :init
  step :apply_birthday

  private

  def init(ctx, users:, **)
    ctx[:model] = users
  end

  def apply_birthday(ctx, model:, segments:, **)
    return true unless segments.key?('birthday')

    ctx[:model] = Segments::Birthday.call(users: model, segment: segments['birthday']).model
  end
end
