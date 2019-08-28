class CreateOrgs < ActiveRecord::Migration[6.0]
  def change
    create_table :orgs do |t|
      t.string :name
      t.string :description
      t.jsonb :properties
      t.jsonb :display_properties

      t.timestamps
    end
  end
end
