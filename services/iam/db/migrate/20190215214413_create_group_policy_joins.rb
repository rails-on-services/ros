class CreateGroupPolicyJoins < ActiveRecord::Migration[6.0]
  def change
    create_table :group_policy_joins do |t|
      t.references :group, foreign_key: true
      t.references :policy, foreign_key: true

      t.timestamps
    end
  end
end
