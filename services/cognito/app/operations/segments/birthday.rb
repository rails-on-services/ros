# frozen_string_literal: true

module Segments
  class Birthday < Ros::ActivityBase
    step :init
    step :verify_segment
    failed :incorrect_segment, Output(:success) => End(:failure)
    step :apply_segment
    failed :segment_not_applied, Output(:success) => End(:failure)

    private

    def init(ctx, segment:, **)
      if segment.match(/^\d{2}$/)
        ctx[:date] = Date.strptime(segment, '%m')
        ctx[:segment] = 'this_month'
      elsif segment.match(/^\d{2}-\d{2}$/)
        ctx[:date] = Date.strptime(segment, '%m-%d')
        ctx[:segment] = 'this_day'
      else
        ctx[:date] = Time.zone.today
      end
    end

    def verify_segment(_ctx, segment:, **)
      %w[this_day this_month].include?(segment)
    end

    def incorrect_segment(_ctx, errors:, segment:, **)
      errors.add(:segment, "Incorrect birthday segment value: #{segment}")
    end

    def apply_segment(ctx, users:, segment:, date:, **)
      ctx[:model] = send(segment, users, date)
    end

    def segment_not_applied(_ctx, errors:, segment:, **)
      errors.add(:model, "Can't apply birthday segment: #{segment}")
    end

    def this_day(users, date)
      users.where("TO_CHAR(birthday, 'DD-MM') = TO_CHAR(DATE(?), 'DD-MM')", date)
    end

    def this_month(users, date)
      users.where("TO_CHAR(birthday, 'MM') = TO_CHAR(DATE(?), 'MM')", date)
    end
  end
end
