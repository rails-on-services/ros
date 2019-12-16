# frozen_string_literal: true

module HasAttachment
  extend ActiveSupport::Concern

  included do
    has_one_attached :file
  end

  def after_attach(io); end

  def upload(io:)
    file.purge # ensure any existing attachment is removed
    self.class.upload(io: io, owner: self)
  end

  class_methods do
    def upload(io:, owner: nil)
      owner ||= create
      io_filename = io.path if io.respond_to?(:path)
      io_filename = io.original_filename if io.respond_to?(:original_filename)
      # Set the bucket before uploading file
      Rails.logger.debug("Setting bucket to #{bucket_name}")
      service.set_bucket(bucket_name)
      upload = ActiveStorage::Blob.new.tap do |blob|
        blob.filename = io_filename
        blob.key = "#{object_root}/#{blob_key(owner, blob)}"
        blob.upload(io)
        blob.save!
      end
      owner.file.attach(upload)
      owner.after_attach(io)
      Rails.logger.debug("Uploaded #{upload.key} to bucket #{bucket_name}")
      owner
    rescue Aws::S3::Errors::NoSuchBucket => e
      # TODO: This should send an exception report to sentry
      owner.errors.add(:file, e.message)
      owner.delete
    rescue ActiveRecord::RecordNotUnique => e
      # TODO: This should send an exception report to sentry
      owner.errors.add(:file, e.message)
      owner.delete
    rescue StandardError => e
      owner.errors.add(:file, e.message)
      owner.delete
    end

    def blob_key(_owner, blob)
      blob.class.generate_unique_secure_token
    end

    def object_root
      @object_root ||= Pathname.new([feature_set, object_scope, tenant_schema, object_dir].compact.join('/'))
    end

    # NOTE: feature_set will have a value for uat and blank for all others (dev, test, staging and production)
    def feature_set; Settings.feature_set end

    def object_scope; 'tenants' end

    # TODO: if we need the tenant in a different format, that should be the responsibility of the Tenant model
    def tenant_schema; Apartment::Tenant.current.gsub('_', '') end

    # Examples: uploads, downloads; used on sftp service
    def object_dir; nil end

    delegate :name, to: :bucket, prefix: true

    def bucket; Settings.infra.resources.storage.buckets[bucket_service] end

    def bucket_service; Settings.infra.resources.storage.services[service_name] end

    def service_name; table_name end

    def service; ActiveStorage::Blob.service end
  end
end
