class CreateUserPools < ActiveRecord::Migration[6.0]
  def change
    create_table :user_pools do |t|
      t.references :user, foreign_key: true
      t.references :pool, foreign_key: true

      t.timestamps
    end
  end
end
