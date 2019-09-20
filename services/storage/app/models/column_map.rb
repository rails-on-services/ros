# frozen_string_literal: true

class ColumnMap < Storage::ApplicationRecord
  belongs_to :transfer_map
  validate :column_name_is_eligible

  private

  def column_name_is_eligible
    errors.add(:illegible_column_name, "#{name} is illegible column_name") unless service_columns.include?(name)
  end

  def service_columns
    @service_columns ||=
      transfer_map.service_name.constantize.where(model_name: transfer_map.target).first['model_columns']
  end
end
