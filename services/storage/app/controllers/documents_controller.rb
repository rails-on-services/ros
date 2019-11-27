# frozen_string_literal: true

class DocumentsController < Storage::ApplicationController
  include HasAttachmentController

  def create
    file = model_class.upload(io: params[:file])
    if file.persisted?
      render status: :ok, json: serialize_resource(DocumentResource, DocumentResource.new(file, context))
    else
      resource = ApplicationResource.new(file, nil)
      handle_exceptions JSONAPI::Exceptions::ValidationErrors.new(resource)
    end
  end

  def model_class
    self.class.name.gsub('Controller', '').singularize.constantize
  end
end
