# frozen_string_literal: true

Ros.platform.configure do |config|
  config.compose_files += %w(compose/base.yml compose/services.yml compose/mounts.yml)
end
