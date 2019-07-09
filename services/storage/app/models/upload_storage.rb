# frozen_string_literal: true

class UploadStorage < Storage::ApplicationRecord
  belongs_to :tenant
  has_many_attached :files

  def self.find_or_create!
    find_or_create_by(tenant_id: current_tenant.id)
  end

  def upload!(io:)
    upload = ActiveStorage::Blob.new.tap do |blob|
      blob.filename = io.original_filename
      blob.key = destination_path + blob.class.generate_unique_secure_token
      blob.upload io
      blob.save!
    end
    files.attach upload
  end

  private

  def destination_path
    "#{current_tenant.schema_name.delete('_')}/"
  end
end