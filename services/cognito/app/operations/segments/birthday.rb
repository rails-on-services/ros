# frozen_string_literal: true

module Segments
  class Birthday < Ros::ActivityBase
    step :verify_segment
    failed :incorrect_segment, Output(:success) => End(:failure)
    step :apply_segment
    failed :segment_not_applied, Output(:success) => End(:failure)

    private

    def verify_segment(_ctx, segment:, **)
      %w[this_day this_month].include?(segment)
    end

    def incorrect_segment(_ctx, errors:, segment:, **)
      errors.add(:segment, "Incorrect birthday segment value: #{segment}")
    end

    def apply_segment(ctx, users:, segment:, **)
      ctx[:model] = send(segment, users)
    end

    def segment_not_applied(_ctx, errors:, segment:, **)
      errors.add(:model, "Can't apply birthday segment: #{segment}")
    end

    def this_day(users)
      users.where("TO_CHAR(birthday, 'DD-MM') = TO_CHAR(DATE(?), 'DD-MM')", Time.zone.today)
    end

    def this_month(users)
      users.where("TO_CHAR(birthday, 'MM') = TO_CHAR(DATE(?), 'MM')", Time.zone.today)
    end
  end
end
