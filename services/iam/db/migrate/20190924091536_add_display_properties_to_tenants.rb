class AddDisplayPropertiesToTenants < ActiveRecord::Migration[6.0]
  def change
    add_column :tenants, :display_properties, :jsonb, default: {}
  end
end
