# frozen_string_literal: true

module ActAsStackTraceableConcern
  extend ActiveSupport::Concern

  class_methods do
    def act_as_stack_traceable
      yield
    end

    def logged_action(action, options = {})
      as = options.fetch(:as)
      on = options.fetch(:on)
      _condition = options.fetch(:if, -> { true })
      send("after_#{on}") do
        send(action) unless send(as).nil?
      end
    end
  end
end
