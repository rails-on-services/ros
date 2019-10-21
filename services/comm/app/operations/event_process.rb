# frozen_string_literal: true

class EventProcess < Trailblazer::Operation
  step :work

  private

  def work(params)
    binding.pry
    true
  end
end
