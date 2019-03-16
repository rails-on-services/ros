class CreateUserPolicyJoins < ActiveRecord::Migration[6.0]
  def change
    create_table :user_policy_joins do |t|
      t.references :user, foreign_key: true
      t.references :policy, foreign_key: true

      t.timestamps
    end
  end
end
