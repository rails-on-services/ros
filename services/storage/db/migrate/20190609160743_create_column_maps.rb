# frozen_string_literal: true

class CreateColumnMaps < ActiveRecord::Migration[6.0]
  def change
    create_table :column_maps do |t|
      t.references :transfer_map, null: false, foreign_key: true
      t.string :name
      t.string :user_name

      t.timestamps
    end
  end
end
