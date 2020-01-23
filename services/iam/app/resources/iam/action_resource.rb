# frozen_string_literal: true

module Iam
  class ActionResource < Iam::ApplicationResource
    # caching
    attributes :name, :resource, :action_type

    def action_type
      @model.type
    end
  end
end

# class ListActionResource < ActionResource; end

# class ReadActionResource < ActionResource; end

# class WriteActionResource < ActionResource; end
