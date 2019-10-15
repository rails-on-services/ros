# frozen_string_literal: true

namespace :ros do
  namespace :avro do
    desc 'Register Avro schemas'
    task :register do
      Rails.application.initialize! unless Rails.application.initialized?

      Dir['./doc/schemas/**/*.avsc'].each do |schema|
        parsed_content = JSON.parse(File.read(schema))
        avro = Rails.configuration.x.event_logger.avro
        avro.send(:register_schema, "#{parsed_content['name']}-value", parsed_content['name'], nil)
      end
    end
  end
end
