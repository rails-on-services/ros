# frozen_string_literal: true

class CreateActions < ActiveRecord::Migration[6.0]
  def change
    create_table :actions do |t|
      t.string :name, null: false, index: { unique: true }
      t.string :effect, null: false
      t.string :resource, null: false
      t.string :segment, null: false, default: :all

      t.timestamps null: false
    end
  end
end
