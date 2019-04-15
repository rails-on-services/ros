# frozen_string_literal: true

class CreateActions < ActiveRecord::Migration[6.0]
  def change
    create_table :actions do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :type, null: false
      t.string :resource

      t.timestamps
    end
  end
end
