# frozen_string_literal: true

class CreatePolicyActions < ActiveRecord::Migration[6.0]
  def change
    create_table :policy_actions do |t|
      t.references :policy, foreign_key: true
      t.references :action, foreign_key: true

      t.timestamps
    end
    add_index :policy_actions, %i[policy_id action_id], unique: true
  end
end
