# frozen_string_literal: true

class DocumentResource < Storage::ApplicationResource
  attributes :transfer_map, :target, :column_map, :blob, :platform_event_state,
             :url

  def transfer_map
    @model.transfer_map&.name
  end

  def target
    @model.transfer_map&.target
  end

  def column_map
    @model.column_map
  end

  def url
    @model.file.attached? ? Ros::Infra.resources.storage.app.presigned_url(@model.file.blob.key) : ''
  end

  def blob
    JSON.parse((@model.file.attached? ? @model.file.blob : {}).to_json)
  end
end
