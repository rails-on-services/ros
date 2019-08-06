# frozen_string_literal: true

class CreateUploads < ActiveRecord::Migration[6.0]
  def change
    create_table :uploads do |t|
      t.string :name
      t.string :etag
      t.integer :size
      t.integer :transfer_map_id

      t.timestamps
    end
  end
end
