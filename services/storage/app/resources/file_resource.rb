# frozen_string_literal: true

class FileResource < Storage::ApplicationResource
  attributes :filename, :extension, :url

  def extension
    @model.filename.extension_without_delimiter
  end

  def url
    @model.service_url
  end

  def urn
    @model.key
  end

  def updated_at
    created_at
  end

end