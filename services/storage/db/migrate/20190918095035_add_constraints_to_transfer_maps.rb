class AddConstraintsToTransferMaps < ActiveRecord::Migration[6.0]
  def change
    change_column_null :transfer_maps, :name, false
    change_column_null :transfer_maps, :service, false
    change_column_null :transfer_maps, :target, false
    change_column_null :transfer_maps, :created_at, false
    change_column_null :transfer_maps, :updated_at, false
  end
end
