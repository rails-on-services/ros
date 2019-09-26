# frozen_string_literal: true

class Upload < Storage::ApplicationRecord
  include WorkflowActiverecord
  belongs_to :transfer_map, optional: true

  # before_create :assign_transfer_map

  # enum workflow_state: %i[pending failed done]

  workflow do
    state :pending do
      event :succeed, transitions_to: :done
      event :fail, transitions_to: :failed
    end
    state :failed
    state :done
  end

  def succeed
    assign_transfer_map
    update(transfer_map_id: transfer_map_id)
  end

  def assign_transfer_map
    self.transfer_map_id ||= begin
      file_columns = File.readlines(local_path).first.chomp.split(',').sort
      TransferMap.match(file_columns).id
    rescue => e
      nil
    end
  end

  def queue_to_services
    [transfer_map.service]
  end

  def remote_path
    # "home/222222222/uploads/#{name}"
    "storage/sftp/home/#{current_tenant.schema_name.gsub('_', '')}/uploads/#{name}"
  end

  def local_path
    get
    "#{Rails.root}/tmp/#{remote_path}"
  end

  def get; Rails.configuration.x.infra.resources.storage.primary.get(remote_path) end

  def put; Rails.configuration.x.infra.resources.storage.primary.put(remote_path) end

  def column_map
    transfer_map&.hash_of_columns
  end

  def as_json(*)
    super.merge(
      'urn' => to_urn,
      'target' => transfer_map&.target,
      'remote_path' => remote_path,
      'column_map' => column_map
    )
  end
end
