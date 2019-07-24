class AddConfirmableToDevise < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :confirmation_token, :string
    add_column :users, :confirmed_at, :datetime
    add_column :users, :confirmation_sent_at, :datetime
    add_column :users, :username, :string
    rename_column :users, :email_address, :email
    rename_column :users, :phone_number, :phone


    add_index :users, :confirmation_token, unique: true
  end

end
