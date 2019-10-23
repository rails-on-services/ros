# frozen_string_literal: true

class DocumentResource < Storage::ApplicationResource
  attributes :transfer_map, :target, :column_map, :blob, :platform_event_state

  def transfer_map; @model.transfer_map.name end

  def target; @model.transfer_map.target end

  def column_map; @model.column_map end

  def blob; JSON.parse(@model.file.blob.to_json) end
end
