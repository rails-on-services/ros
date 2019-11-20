# frozen_string_literal: true

namespace :ros do
  namespace :avro do
    desc 'Register Avro schemas'
    task :register do
      Rails.application.initialize! unless Rails.application.initialized?
      next unless Settings.event_logging.enabled

      Dir['./doc/schemas/**/*.avsc'].each do |schema|
        parsed_content = JSON.parse(File.read(schema))
        avro = Rails.configuration.x.event_logger.avro
        avro.send(:register_schema, "#{parsed_content['name']}-value", parsed_content['name'], nil)
      end
    end

    desc 'Build Avro Schemas'
    task :build do
      def name(file_path)
        file_name = file_path.split('/').last
        file_name.slice!('.rb')
        file_name
      end

      Dir['./app/models/*.rb'].each do |file|
        model_name = name(file)
        puts "Generating #{model_name} avsc file"
        `rails generate avro #{model_name} --force`
      end
    end
  end
end
