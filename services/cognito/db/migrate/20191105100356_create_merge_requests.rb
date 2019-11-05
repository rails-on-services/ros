class CreateMergeRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :merge_requests do |t|
      t.bigint :final_user_id
      t.jsonb :ids_to_merge, null: false
      t.timestamps
    end
  end
end
