# frozen_string_literal: true

Rails.application.initialize!

namespace :ros do
  namespace :avro do
    desc 'Register Avro schemas'
    task :register do
      # binding.pry
      Dir['./doc/schemas/**/*.avsc'].each do |schema|
        parsed_content = JSON.parse(File.read(schema))
        avro = Rails.configuration.x.event_logger.avro
        avro.send(:register_schema, "#{parsed_content['name']}-value", parsed_content['name'], nil)
      end
    end
  end
end
