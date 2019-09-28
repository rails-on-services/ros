# frozen_string_literal: true

class DocumentResource < Storage::ApplicationResource
  attributes :name, :etag, :size, :transfer_map_id
  attributes :bucket_name, :blob

  def bucket_name; @model.class.bucket_name end

  def blob; JSON.parse(@model.file.blob.to_json) end
end
