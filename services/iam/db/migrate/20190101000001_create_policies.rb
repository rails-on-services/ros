# frozen_string_literal: true

class CreatePolicies < ActiveRecord::Migration[6.0]
  def change
    create_table :policies do |t|
      t.string :name, null: false, index: { unique: true }

      t.timestamps
    end
  end
end
