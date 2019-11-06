# frozen_string_literal: true

namespace :ros do
  namespace :avro do
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
