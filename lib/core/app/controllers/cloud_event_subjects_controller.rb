# frozen_string_literal: true

class CloudEventSubjectsController < ApplicationController
  skip_before_action :authenticate_it!, only: [:index]
  skip_after_action :set_headers!, only: [:index]

  def index
    render json: json_resources(resource_class: CloudEventSubjectResource, records: resources)
  end

  private

  def resources
    path = "#{Settings.event_logging.config.schemas_path}/#{Settings.service.name}"
    Dir["#{path}/*.avsc"].map do |file_name|
      CloudEventSubject.new(name(file_name))
    end.compact
  end

  def name(file_name)
    file_name.slice!('.avsc')
    "#{Settings.service.name}.#{file_name}"
  end
end
