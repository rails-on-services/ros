# frozen_string_literal: true

class ActivityBase < Trailblazer::Activity::Railway
  step :setup_context

  def setup_context(ctx, _params)
    ctx[:errors] = ActiveModel::Errors.new(self)
  end
end
