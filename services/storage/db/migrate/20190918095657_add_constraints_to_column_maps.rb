class AddConstraintsToColumnMaps < ActiveRecord::Migration[6.0]
  def change
    change_column_null :column_maps, :name, false
    change_column_null :column_maps, :user_name, false
    change_column_null :column_maps, :created_at, false
    change_column_null :column_maps, :updated_at, false
    add_index :column_maps, [:name, :transfer_map_id]
  end
end
