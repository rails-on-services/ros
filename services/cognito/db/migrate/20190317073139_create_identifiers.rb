class CreateIdentifiers < ActiveRecord::Migration[6.0]
  def change
    create_table :identifiers do |t|
      t.string :name
      t.string :value
      t.references :user, foreign_key: true
      t.jsonb :properties

      t.timestamps
    end
  end
end
