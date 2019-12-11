# frozen_string_literal: true

module Segments
  class ExceptIds < Ros::ActivityBase
    step :verify_segment
    failed :incorrect_segment, Output(:success) => End(:failure)
    step :apply_segment
    failed :segment_not_applied, Output(:success) => End(:failure)

    private

    def verify_segment(_ctx, segment:, **)
      segment.is_a?(Array)
    end

    def incorrect_segment(_ctx, errors:, segment:, **)
      errors.add(:segment, "Incorrect except ids segment value: #{segment}")
    end

    def apply_segment(ctx, users:, segment:, **)
      ctx[:model] = users.where.not(id: segment)
    end

    def segment_not_applied(_ctx, errors:, segment:, **)
      errors.add(:model, "Can't apply except ids segment: #{segment}")
    end
  end
end
