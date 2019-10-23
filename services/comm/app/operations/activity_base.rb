# frozen_string_literal: true

class ActivityBase < Trailblazer::Activity::Railway
  def self.human_attribute_name(attr_name, _opts)
    attr_name.humanize
  end

  step :setup_context

  private

  def setup_context(ctx, _params)
    ctx[:errors] = ActiveModel::Errors.new(self)
  end
end
