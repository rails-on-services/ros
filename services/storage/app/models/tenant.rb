# frozen_string_literal: true

class Tenant < Storage::ApplicationRecord
  include Ros::TenantConcern
  # SFTP_USERS_CONF_PATH = 'storage/sftp/config/users.conf'
  SFTP_USERS_CONF_PATH = 'sftp/config/users.conf'

  # after_create :write_tenants_to_sftp_users_conf

  # rubocop:disable Metrics/AbcSize
  def write_tenants_to_sftp_users_conf
    service = ActiveStorage::Blob.service
    service.set_bucket(bucket_name)
    f = Tempfile.new('users.conf')
    self.class.order(:id).all.each do |tenant|
      uid = "1#{'0' * (3 - (tenant.id - 1).to_s.size)}#{tenant.id}"
      f.write("#{tenant.account_id}:pass:#{uid}::uploads,downloads\n")
    end
    f.close
  end

  def service_name; 'sftp' end

  def bucket_name; Settings.infra.resources.storage.buckets[bucket_service] end

  def bucket_service; Settings.infra.resources.storage.services[service_name] end

  # Rails.configuration.x.infra.resources.storage.primary.put(SFTP_USERS_CONF_PATH, f.path)
  # rubocop:enable Metrics/AbcSize
end
