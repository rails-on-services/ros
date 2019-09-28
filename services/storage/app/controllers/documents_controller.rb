# frozen_string_literal: true

class DocumentsController < Storage::ApplicationController
  include HasAttachmentController

  def create
    file = model_class.upload(io: params[:file])
    render status: :ok, json: serialize_resource(DocumentResource, DocumentResource.new(file, context))
  end

  def model_class
    self.class.name.gsub('Controller', '').singularize.constantize
  end
end
