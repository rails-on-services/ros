# frozen_string_literal: true

class CreateTenants < ActiveRecord::Migration[6.0]
  def change
    create_table :tenants do |t|
      t.string :schema_name, null: false, index: { unique: true }
      t.jsonb :properties, null: false, default: {}
      t.jsonb :platform_properties, null: false, default: {}

      t.timestamps
    end
  end
end
