# frozen_string_literal: true

module Segments
  class Age < Ros::ActivityBase
    step :init
    step :verify_segment
    failed :incorrect_segment, Output(:success) => End(:failure)
    step :translate_segment
    step :apply_segment
    failed :segment_not_applied, Output(:success) => End(:failure)

    private

    def init(ctx, segment:, **)
      ctx[:segment] = Array.wrap(segment)
      ctx[:translated_segments] = []
    end

    def verify_segment(_ctx, segment:, **)
      segment.all? { |s| segment_element_valid?(s) }
    end

    def incorrect_segment(_ctx, errors:, segment:, **)
      errors.add(:segment, "Incorrect age segment value: #{segment}")
    end

    def translate_segment(_ctx, segment:, translated_segments:, **)
      segment.each do |element|
        translated_segments << case element
                               when Hash
                                 el = element.with_indifferent_access
                                 date_range(el['from'], el['to'])
                               when String, Integer
                                 date_range(element, element)
                               end
      end
    end

    def apply_segment(ctx, users:, translated_segments:, **)
      ctx[:model] = users.where(birthday: translated_segments)
    end

    def segment_not_applied(_ctx, errors:, segment:, **)
      errors.add(:model, "can't apply age segment: #{segment}")
    end

    def segment_element_valid?(element)
      case element
      when Hash
        element.with_indifferent_access.keys.sort == %w[from to] && element.values.all? { |el| el.to_s.match(/^\d+$/) }
      when String, Integer
        element.to_s.match(/^\d+$/)
      else
        false
      end
    end

    def date_range(from, to, base_date = Time.zone.today)
      Range.new(
        base_date - to.to_i.years - 1.year + 1.day,
        base_date - from.to_i.years
      )
    end
  end
end
