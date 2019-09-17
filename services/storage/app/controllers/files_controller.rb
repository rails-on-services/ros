# frozen_string_literal: true

class FilesController < Storage::ApplicationController

  def index
    render status: 200, json: json_resources(resource_class: FileResource, records: files)
  end

  def create
    file = current_storage.upload! io: params[:file]
    render status: 200, json: json_resources(resource_class: FileResource, records: file)
  end

  private

  def files
    current_storage.files_attachments.preload(:blob)
  end

end