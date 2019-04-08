# frozen_string_literal: true

class CreateTenants < ActiveRecord::Migration[6.0]
  def change
    create_table :tenants do |t|
      t.string :schema_name, null: false, index: { unique: true }, length: 11
      t.jsonb :properties
      t.jsonb :platform_properties
      t.belongs_to :root, null: false, foreign_key: true, index: { unique: true }
      t.string :alias, null: true, index: { unique: true }
      t.string :name
      t.string :state

      t.timestamps null: false
    end
    # https://stackoverflow.com/questions/3170634/how-to-solve-cannot-add-a-not-null-column-with-default-value-null-in-sqlite3
  end
end

