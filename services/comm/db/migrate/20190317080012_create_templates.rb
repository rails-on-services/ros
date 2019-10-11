class CreateTemplates < ActiveRecord::Migration[6.0]
  def change
    create_table :templates do |t|
      t.string :name
      t.string :description
      t.text :content
      t.string :status

      t.timestamps
    end
  end
end
