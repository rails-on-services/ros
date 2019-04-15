class CreateUserCredentials < ActiveRecord::Migration[6.0]
  def change
    create_table :user_credentials do |t|
      t.references :user, foreign_key: true
      t.integer :credential_id, foreign_key: true, index: { unique: true }

      t.timestamps
    end
  end
end
