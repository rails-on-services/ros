# frozen_string_literal: true

module Segments
  class Gender < Ros::ActivityBase
    step :verify_segment
    failed :incorrect_segment, Output(:success) => End(:failure)
    step :apply_segment
    failed :segment_not_applied, Output(:success) => End(:failure)

    private

    def verify_segment(_ctx, segment:, **)
      case segment
      when Array
        (segment - %w[male female other]).empty?
      when String
        %w[male female other any].include?(segment)
      else
        false
      end
    end

    def incorrect_segment(_ctx, errors:, segment:, **)
      errors.add(:segment, "Incorrect gender segment value: #{segment}")
    end

    def apply_segment(ctx, users:, segment:, **)
      ctx[:model] = segment == 'any' ? users : users.where(gender: segment)
    end

    def segment_not_applied(_ctx, errors:, segment:, **)
      errors.add(:model, "Can't apply gender segment: #{segment}")
    end
  end
end
