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
      condition = options.fetch(:if, -> { true })
      send("after_#{on}") do
        if instance_exec(&condition)
          payload = send(as)
          res = send(action)
          ActAsStackTraceable.create(resource_type: self.class.name, resource_id: id, target_resource: as,
                                     payload: payload, response: res.first)
        end
      end
    end
  end
end
