# frozen_string_literal: true

class IamPublicKeyProcess
  METADATA_HASH = { mode: '33188', gid: '100' }.freeze

  class << self
    def call(_json)
      Ros::Infra.resources.storage.app.cp(source_path, target_path, METADATA_HASH.merge(uid: tenant.account_id))
    end

    def source_path; "fs:#{key_file.path.gsub("#{fs_path}/", '')}" end

    def target_path; "#{SftpFile.object_root}/config/sshx/authorized-keys/#{tenant.account_id}" end

    def tenant
      Tenant.find_by(schema_name: Apartment::Tenant.current)
    end

    def key_file
      @key_file ||= tempfile
    end

    def tempfile
      file = Tempfile.new('public_key', fs_path)
      file.write(content)
      file.close
      file
    end

    # TODO: Handle pagination
    def content
      @content ||= Ros::IAM::PublicKey.select(:content).all.map(&:content).join("\n")
    end

    def fs_path; Rails.root.join('tmp', 'fs') end
  end
end
