class ChangeForeignKeyOnColumnMaps < ActiveRecord::Migration[6.0]
  def up
    remove_foreign_key :column_maps, :transfer_maps
    add_foreign_key :column_maps, :transfer_maps, on_delete: :cascade
  end

  def down
    remove_foreign_key :column_maps, :transfer_maps
    add_foreign_key :column_maps, :transfer_maps
  end
end
