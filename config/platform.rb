# frozen_string_literal: true

module Dev
  class Platform < Ros::Platform
    config.compose_project_name = 'ros'
    config.image_repository = 'rails-on-services'
    config.ros_root = Ros.root.join('ros')
  end
end
