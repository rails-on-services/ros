class CreateProviders < ActiveRecord::Migration[6.0]
  def change
    create_table :providers do |t|
      t.string :name
      t.string :type
      t.string :encrypted_credentials
      t.string :encrypted_credentials_iv
      t.string :encrypted_credential_1
      t.string :encrypted_credential_1_iv
      t.string :encrypted_credential_2
      t.string :encrypted_credential_2_iv
      t.string :encrypted_credential_3
      t.string :encrypted_credential_3_iv

      t.timestamps
    end
  end
end
