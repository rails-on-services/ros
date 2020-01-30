# # frozen_string_literal: true

# WaterDrop.setup do |config|
#   kafka_enabled = Settings.dig(:infra, :services, :kafka, :enabled)
#   next unless kafka_enabled

#   config.kafka.seed_brokers = Settings.infra.services.kafka.bootstrap_servers.split(',').map do |broker|
#     "kafka://#{broker}" unless broker.starts_with? 'kafka://'
#   end

#   if Settings.infra.services.kafka.security_protocol == 'SASL_SSL' && Settings.infra.services.kafka.sasl_mechanism == 'PLAIN'
#     config.kafka.sasl_plain_username = Settings.infra.services.kafka.username
#     config.kafka.sasl_plain_password = Settings.infra.services.kafka.password
#   end
#   config.client_id = 'storage-service'
#   config.logger = Rails.logger
# end
