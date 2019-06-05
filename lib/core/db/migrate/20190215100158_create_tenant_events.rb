class CreateTenantEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :tenant_events do |t|
      t.string :resource
      t.string :event
      t.string :destination
    end
  end
end
