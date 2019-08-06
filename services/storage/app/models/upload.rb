# frozen_string_literal: true

class Upload < Storage::ApplicationRecord
  belongs_to :transfer_map, required: false

  before_create :assign_transfer_map

  def assign_transfer_map
    self.transfer_map_id ||= begin
      file_columns = File.readlines(local_path).first.chomp.split(',').sort
      TransferMap.match(file_columns)&.id
    end
  end

  def remote_path
    # "home/222222222/uploads/#{name}"
    "home/#{current_tenant.schema_name.gsub('_', '')}/uploads/#{name}"
  end

  def local_path
    "#{Rails.root}/tmp/#{remote_path}"
  end

  def get; Storage.get(remote_path) end

  def put; Storage.put(remote_path) end

  def column_map
    transfer_map.column_maps.pluck(:user_name, :name).each_with_object({}) do |a, h|
      h[a[0].to_sym] = a[1]
    end
  end

  def as_json(*)
    super.merge(
      'urn' => to_urn,
      'target' => transfer_map.target,
      'remote_path' => remote_path,
      'column_map' => column_map
    )
  end
end
