class CreateTemplates < ActiveRecord::Migration[6.0]
  def change
    create_table :templates do |t|
      t.string :name
      t.string :description
      t.references :campaign_entity, foreign_key: { to_table: :campaigns }
      t.text :content
      t.string :status

      t.timestamps
    end
  end
end
