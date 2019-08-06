# frozen_string_literal: true

class CreateTransferMaps < ActiveRecord::Migration[6.0]
  def change
    create_table :transfer_maps do |t|
      t.string :name
      t.string :description
      t.string :service
      t.string :target

      t.timestamps
    end
  end
end
