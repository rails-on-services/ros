class CreateTemplates < ActiveRecord::Migration[6.0]
  def change
    create_table :templates do |t|
      t.references :campaign, foreign_key: true
      t.text :content
      t.string :status

      t.timestamps
    end
  end
end
