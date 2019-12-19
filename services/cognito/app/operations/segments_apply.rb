# frozen_string_literal: true

class SegmentsApply < Ros::ActivityBase
  step :init
  step :apply_segments
  # step :apply_birthday
  # step :apply_except_ids
  # step :apply_gender
  # step :apply_age

  private

  def init(ctx, users:, **)
    ctx[:model] = users
  end

  def apply_segments(ctx, model:, segments:, errors:, **)
    segments.each do |segment_key, segment_value|
      res = apply_segment(segment_key, segment_value, model, errors)
      return false if res.nil?

      if res.failure?
        ctx[:errors] = res.errors
        return false
      end

      model = res.model
    end
    ctx[:model] = model
  end

  # def apply_segment(segment_class, users, segment_value)
  def apply_segment(segment_key, segment_value, users, errors)
    segment_class = "Segments::#{segment_key.classify}".constantize
    segment_class.call(users: users, segment: segment_value)
  rescue NameError => _e
    errors.add(:segment, "Can't find segmentation class")
    nil
  end

  def apply_birthday(ctx, model:, segments:, **)
    return true unless segments.key?(:birthday)

    applied_segment = Segments::Birthday.call(users: model, segment: segments[:birthday])
    return false if applied_segment.failure?

    ctx[:model] = applied_segment.model
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
