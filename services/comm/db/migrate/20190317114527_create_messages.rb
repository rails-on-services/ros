class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages do |t|
      t.references :provider, foreign_key: true
      t.references :owner, polymorphic: true
      t.string :channel
      t.string :from
      t.string :to
      t.string :body

      t.timestamps
    end
  end
end
