class CreateCredentials < ActiveRecord::Migration[6.0]
  def change
    create_table :credentials do |t|
      t.belongs_to :provider, foreign_key: true
      t.string :key
      t.string :encrypted_secret
      t.string :encrypted_secret_iv

      t.timestamps
    end
    add_index :credentials, %i(provider_id key), unique: true
  end
end
