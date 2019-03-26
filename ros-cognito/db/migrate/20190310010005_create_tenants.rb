class CreateTenants < ActiveRecord::Migration[6.0]
  def change
    create_table :tenants do |t|
      t.string :schema_name, null: false, index: { unique: true }, length: 11
      t.jsonb :properties
      t.jsonb :platform_properties

      t.timestamps
    end
  end
end
