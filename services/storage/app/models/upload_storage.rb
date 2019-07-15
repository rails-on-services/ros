# frozen_string_literal: true

class UploadStorage < Storage::ApplicationRecord
  has_many_attached :files

  def self.find_or_create!
    find_or_create_by(tenant_id: current_tenant.id)
  end

  def upload!(io:)
    upload = ActiveStorage::Blob.new.tap do |blob|
      blob.filename = io.original_filename
      blob.key = "#{current_tenant.schema_name}/#{detect_file_type(io)}/#{blob.class.generate_unique_secure_token}"
      blob.upload io
      blob.save!
    end
    upload if files.attach upload
  end

  private

  def detect_file_type(io)
    return :image if io.content_type.start_with?('image')
    :document
  end
end