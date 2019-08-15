# frozen_string_literal: true

class ColumnMapResource < Storage::ApplicationResource
  attributes :name, :user_name
  has_one :transfer_map
end
