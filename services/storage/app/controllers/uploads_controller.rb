# frozen_string_literal: true

class UploadsController < Storage::ApplicationController

  def index
    render status: 200, json: json_resources(FileResource, files)
  end

  def create
    current_storage.upload! io: params[:file]
  end

  private

  def files
    current_storage.files_attachments.preload(:blob)
  end

end