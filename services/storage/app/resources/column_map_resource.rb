# frozen_string_literal: true

class ColumnMapResource < Storage::ApplicationResource
  attributes :name, :user_name, :transfer_map_id
  has_one :transfer_map
end
