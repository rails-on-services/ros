# frozen_string_literal: true

module Ros
  module Iam
    class ActionResource < Ros::Iam::ApplicationResource
      # caching
      attributes :name, :resource, :action_type

      def action_type
        @model.type
      end
    end
  end
end

# class ListActionResource < ActionResource; end

# class ReadActionResource < ActionResource; end

# class WriteActionResource < ActionResource; end
