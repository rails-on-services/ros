class CreateChownRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :chown_requests do |t|
      t.bigint :to_id
      t.jsonb :from_ids, null: false
      t.timestamps
    end
  end
end
