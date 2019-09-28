# frozen_string_literal: true

class ImagesController < Storage::ApplicationController
  include HasAttachmentController

  def create
    file = model_class.upload(io: params[:file])
    render status: :ok, json: serialize_resource(ImageResource, ImageResource.new(file, context))
  end

  def model_class
    self.class.name.gsub('Controller', '').singularize.constantize
  end
end
