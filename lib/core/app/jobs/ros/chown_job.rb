# frozen_string_literal: true

module Ros
  class ChownJob < Ros::ApplicationJob
    def operation_class
      "#{Settings.service.name}::Chown".classify.constantize
    end
  end
end
