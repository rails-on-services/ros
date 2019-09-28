# frozen_string_literal: true

class ImageResource < Storage::ApplicationResource
  attributes :bucket_name, :blob, :cdn, :url

  # TODO: refactor this inefficent way to get the CDN
  def cdn
    Settings.infra.resources.cdns.to_hash.dup.select do |_k, v|
      v[:bucket].eql?(@model.class.bucket_service)
    end.first.last[:url]
  end

  def url; "#{cdn}/#{@model.file.blob.key}" end

  def bucket_name; @model.class.bucket_name end

  def blob; JSON.parse(@model.file.blob.to_json) end
end
