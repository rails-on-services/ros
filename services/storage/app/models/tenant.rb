# frozen_string_literal: true

class Tenant < Storage::ApplicationRecord
  include Ros::TenantConcern

  after_commit :write_tenants_to_sftp_users_conf

  def write_tenants_to_sftp_users_conf
    self.class.write_tenants_to_sftp_users_conf
  end

  def self.write_tenants_to_sftp_users_conf
    Apartment::Tenant.switch('public') do
      SftpFile.find_or_create_by!(key: 'config/users.conf').upload(io: File.open(sftp_user_content))
    end
  end

  def self.sftp_user_content
    file = Tempfile.new('users.conf')
    order(:id).all.each do |tenant|
      file.write("#{tenant.account_id}:pass:#{tenant.account_id}::uploads,downloads\n")
    end
    file.close
    file
  end
end
