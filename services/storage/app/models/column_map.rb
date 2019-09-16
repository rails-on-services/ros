# frozen_string_literal: true

class ColumnMap < Storage::ApplicationRecord
  belongs_to :transfer_map
  validate :eligible_column_name

  private

  def eligible_column_name
    service_columns = transfer_map.service_name.constantize.where(model_name: transfer_map.target).first['model_columns']
    errors.add(:illegible_column_name, "#{name} is illegible column_name") unless service_columns.include?(name)
  end
end
