# frozen_string_literal: true

require 'ros/core'
require 'ros/storage/engine'

module Ros
  class << self
    def excluded_table_names
      %w[schema_migrations ar_internal_metadata tenant_events platform_events active_storage_blobs
         active_storage_attachments sftp_files]
    end

    def excluded_models; %w[Tenant SftpFile] end
  end
end

module Storage
  module Methods
    # rubocop:disable Naming/AccessorMethodName
    def set_bucket(bucket)
      return unless @client

      @bucket = @client.bucket(bucket)
    end
    # rubocop:enable Naming/AccessorMethodName
  end
end
