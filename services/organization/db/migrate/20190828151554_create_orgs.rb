class CreateOrgs < ActiveRecord::Migration[6.0]
  def change
    create_table :orgs do |t|
      t.string :name
      t.string :description
      t.jsonb :properties, null: false, default: {}

      t.timestamps
    end
  end
end
