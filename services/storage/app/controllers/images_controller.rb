# frozen_string_literal: true

class ImagesController < Storage::ApplicationController
  include CreatableAttachment

  def create
    file = model_class.upload(io: params[:file])
    if file.persisted?
      render status: :ok, json: serialize_resource(ImageResource, ImageResource.new(file, context))
    else
      resource = ApplicationResource.new(file, nil)
      handle_exceptions JSONAPI::Exceptions::ValidationErrors.new(resource)
    end
  end
end
