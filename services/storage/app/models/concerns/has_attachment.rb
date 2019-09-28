# frozen_string_literal: true

module HasAttachment
  extend ActiveSupport::Concern

  included do
    has_one_attached :file
  end

  class_methods do
    def upload(io:)
      owner = create
      service.set_bucket(bucket_name)
      upload = ActiveStorage::Blob.new.tap do |blob|
        blob.filename = io.original_filename
        blob.key = "#{object_root}/#{blob.class.generate_unique_secure_token}"
        blob.upload(io)
        blob.save!
      end
      owner.file.attach(upload)
      owner
    end

    def object_root
      @object_root ||= Pathname.new([feature_set, object_scope, tenant_schema, object_dir].compact.join('/'))
    end

    # NOTE: feature_set will have a value for uat and blank for all others (dev, test, staging and production)
    def feature_set; Settings.feature_set end

    def object_scope; 'tenants' end

    def tenant_schema; Apartment::Tenant.current.gsub('_', '') end

    # Examples: uploads, downloads; used on sftp service
    def object_dir; nil end

    def bucket_name; Settings.infra.resources.storage.buckets[bucket_service] end

    def bucket_service; Settings.infra.resources.storage.services[service_name] end

    def service_name; table_name end

    def service; ActiveStorage::Blob.service end
  end
end
