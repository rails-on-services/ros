class CreateChownResults < ActiveRecord::Migration[6.0]
  def change
    create_table :chown_results do |t|
      t.references :chown_request
      t.string :service_name
      t.bigint :from_id
      t.bigint :to_id
      t.string :status
      t.timestamps
    end
  end
end
