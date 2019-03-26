# frozen_string_literal: true

class CreateEndpoints < ActiveRecord::Migration[6.0]
  def change
    create_table :endpoints do |t|
      t.string :url, null: false, index: { unique: true }
      t.references :target, polymorphic: true
      t.jsonb :properties

      t.timestamps
    end
  end
end
