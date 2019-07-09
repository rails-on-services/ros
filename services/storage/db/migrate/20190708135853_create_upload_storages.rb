class CreateUploadStorages < ActiveRecord::Migration[6.0]
  def change
    create_table :upload_storages do |t|
      t.references :tenant, null: false

      t.timestamps
    end
  end
end
