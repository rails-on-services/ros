# frozen_string_literal: true

class TransferMap < Storage::ApplicationRecord
  has_many :column_maps
  validates :name, :service, :target, presence: true
  validate :service_is_valid
  validate :target_is_valid, if: -> { Ros.api_calls_enabled }

  # rubocop:disable Rails/FindEach
  def self.match(columns_to_match)
    all.each do |tmap|
      columns = tmap.list_of_columns
      break tmap if columns == columns_to_match
    end
  end
  # rubocop:enable Rails/FindEach

  def service_name
    "Ros::#{service&.classify}::FileFingerprint"
  end

  def list_of_columns
    column_maps.pluck(:user_name).sort
  end

  def hash_of_columns
    column_maps.pluck(:user_name, :name).each_with_object({}) { |a, h| h[a[0].to_sym] = a[1] }
  end

  private

  def service_is_valid
    service_name.constantize
  rescue NameError
    errors.add(:invalid_service_name, "#{service_name} is invalid service name")
  end

  def target_is_valid
    raise unless service_name.constantize.where(model_name: target).any?
  rescue StandardError
    errors.add(:invalid_target, "#{target} is invalid target for #{service_name}")
  end
end
