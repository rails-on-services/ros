# frozen_string_literal: true

class CreateRolePolicyJoins < ActiveRecord::Migration[6.0]
  def change
    create_table :role_policy_joins do |t|
      t.references :role, foreign_key: true
      t.references :policy, foreign_key: true

      t.timestamps
    end
  end
end
