class CreatePublicKeys < ActiveRecord::Migration[6.0]
  def change
    create_table :public_keys do |t|
      t.references :user
      t.string :content

      t.timestamps
    end
  end
end
