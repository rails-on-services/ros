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

  # rubocop:disable Metrics/BlockLength
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  class_methods do
    def upload(io:, owner: nil)
      owner ||= create
      io_filename = io.path if io.respond_to?(:path)
      io_filename = io.original_filename if io.respond_to?(:original_filename)
      upload = ActiveStorage::Blob.new.tap do |blob|
        blob.filename = io_filename
        blob.key = "#{object_root}/#{blob_key(owner, blob)}"
        blob.upload(io)
        blob.save!
      end
      service.set_bucket(bucket_name)
      owner.file.attach(upload)
      owner.after_attach(io)
      owner
    rescue Aws::S3::Errors::NoSuchBucket => error
      Rails.logger.warn("Bucket not found #{bucket_name}")
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

    def tenant_schema; Apartment::Tenant.current.gsub('_', '') end

    # Examples: uploads, downloads; used on sftp service
    def object_dir; nil end

    def bucket_name; bucket.name end

    def bucket; Settings.infra.resources.storage.buckets[bucket_service] end

    def bucket_service; Settings.infra.resources.storage.services[service_name] end

    def service_name; table_name end

    def service; ActiveStorage::Blob.service end
  end
  # rubocop:enable Metrics/BlockLength
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
