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
      ctx[:base_date] = Time.zone.today
      ctx[:segment] = Array.wrap(segment)
      ctx[:translated_segments] = []
    end

    def verify_segment(_ctx, segment:, **)
      segment.each do |element|
        return false unless verify_segment_element(element)
      end
    end

    def incorrect_segment(_ctx, errors:, segment:, **)
      errors.add(:segment, "Incorrect age segment value: #{segment}")
    end

    def translate_segment(_ctx, segment:, base_date:, translated_segments:, **)
      segment.each do |element|
        case element
        when Hash
          el = element.with_indifferent_access
          translated_segments << ((base_date - el['to'].to_i.years - 1.year + 1.day)..(base_date - el['from'].to_i.years))
        when String, Integer
          translated_segments << ((base_date - element.to_i.years - 1.year + 1.day)..(base_date - element.to_i.years))
        end
      end
    end

    def apply_segment(ctx, users:, translated_segments:, **)
      ctx[:model] = users.where(birthday: translated_segments)
    end

    def segment_not_applied(_ctx, errors:, segment:, **)
      errors.add(:model, "Can't apply age segment: #{segment}")
    end

    def verify_segment_element(element)
      case element
      when Hash
        element.with_indifferent_access.keys.sort == %w[from to] && element.values.all? { |el| el.to_s.match(/^\d+$/) }
      when String, Integer
        element.to_s.match(/^\d+$/)
      else
        false
      end
    end
  end
end
