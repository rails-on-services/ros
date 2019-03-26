class CreatePools < ActiveRecord::Migration[6.0]
  def change
    create_table :pools do |t|
      t.string :name, index: { unique: true }
      t.jsonb :properties

      t.timestamps
    end
  end
end
