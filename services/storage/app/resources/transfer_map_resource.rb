# frozen_string_literal: true

class TransferMapResource < Storage::ApplicationResource
  attributes :name, :description, :service, :target
  has_many :column_maps
end
