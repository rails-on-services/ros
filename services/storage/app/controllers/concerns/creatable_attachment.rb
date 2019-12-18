# frozen_string_literal: true

module CreatableAttachment
  extend ActiveSupport::Concern

  def create
    file = model_class.upload(io: params[:file])
    render status: :ok, json: json_resources(resource_class: FileResource, records: file)
  end

  def model_class
    self.class.name.gsub('Controller', '').singularize.constantize
  end
end
