# frozen_string_literal: true

class SegmentsApply < Ros::ActivityBase
  step :init
  step :apply_birthday
  step :apply_except_ids
  step :apply_gender
  step :apply_age

  private

  def init(ctx, users:, **)
    ctx[:model] = users
  end

  def apply_birthday(ctx, model:, segments:, **)
    return true unless segments.key?(:birthday)

    ctx[:model] = Segments::Birthday.call(users: model, segment: segments[:birthday]).model
  end

  def apply_except_ids(ctx, model:, segments:, **)
    return true unless segments.key?(:except_ids)

    ctx[:model] = Segments::ExceptIds.call(users: model, segment: segments[:except_ids]).model
  end

  def apply_gender(ctx, model:, segments:, **)
    return true unless segments.key?('gender')

    ctx[:model] = Segments::Gender.call(users: model, segment: segments['gender']).model
  end

  def apply_age(ctx, model:, segments:, **)
    return true unless segments.key?('age')

    ctx[:model] = Segments::Age.call(users: model, segment: segments['age']).model
  end
end
