# frozen_string_literal: true

Ros.platform.configure do |config|
  config.compose_files += %w(compose/base.yml compose/services.yml compose/nginx.yml compose/mounts.yml)
  config.compose_files += %w(ros/compose/services.yml ros/compose/nginx.yml ros/compose/mounts.yml) if Ros.has_ros?
end
