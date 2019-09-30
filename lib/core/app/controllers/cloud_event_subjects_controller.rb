class CloudEventSubjectsController < ApplicationController
  def index
    # binding.pry
    render json: {'hello': 'world'}
    # render json: json_resources(resource_class: CloudEventSubjectResource, records: resources)
  end

  private

  def resources
    # binding.pry
    # @TODO: Add proper filters based on resource class
    # if params.dig(:filter, :model_name)
    #   models.select! { |model| model.model_name.downcase == params[:filter][:model_name].downcase }
    # end
    # models.map! { |model| FileFingerprintResource.new(model, nil) }
  end

  # This method smells of :reek:ManualDispatch
  def models
    # @models ||= Ros.table_names.map do |table|
    #   klass = table.classify.constantize
    #   columns = klass.respond_to?(:file_fingerprint_attributes) ? klass.file_fingerprint_attributes : klass.column_names
    #   FileFingerprint.new(table.classify, columns)
    # end.compact
  end
end
