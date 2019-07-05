# frozen_string_literal: true

class UploadResource < Storage::ApplicationResource
  attributes :name, :etag, :size, :transfer_map_id
  has_one
end
