# frozen_string_literal: true

class SftpFile < ApplicationRecord
  include HasAttachment

  class << self
    def object_scope; 'services' end

    def tenant_schema; 'sftp' end

    def service_name; 'sftp' end
  end

  def self.blob_key(owner, _blob)
    owner.key
  end
end
