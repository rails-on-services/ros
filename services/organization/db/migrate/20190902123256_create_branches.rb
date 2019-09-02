class CreateBranches < ActiveRecord::Migration[6.0]
  def change
    create_table :branches do |t|
      t.references :org, foreign_key: true

      t.string :name
      t.jsonb :properties, null: false, default: {}

      t.timestamps
    end
  end
end
