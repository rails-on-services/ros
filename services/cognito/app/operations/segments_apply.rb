# frozen_string_literal: true

class SegmentsApply < Ros::ActivityBase
  step :init
  step :apply_segments
  failed :unset_model

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

  def apply_segment(segment_key, segment_value, users, errors)
    segment_class = "Segments::#{segment_key.classify}".constantize
    segment_class.call(users: users, segment: segment_value)
  rescue NameError => _e
    errors.add(:segment, "can't find segmentation class")
    nil
  end

  def unset_model(ctx, **)
    ctx[:model] = nil
  end
end
