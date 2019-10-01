class CloudEventSubjectsController < ApplicationController
  def index
    render json: json_resources(resource_class: CloudEventSubjectResource, records: resources.compact)
  end

  private

  def resources
    path = "#{Settings.event_logging.config.schemas_path}/#{Settings.service.name}"
    Dir.foreach(path).map do |file_name|
      next unless file_name.end_with?('.avsc')

      CloudEventSubject.new(name(file_name))
    end
  end

  def name(file_name)
    file_name.slice!('.avsc')
    "#{Settings.service.name}.#{file_name}"
  end
end
