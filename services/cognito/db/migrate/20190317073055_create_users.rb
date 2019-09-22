# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :primary_identifier, index: { unique: true }
      t.string :title
      t.string :first_name
      t.string :last_name
      t.string :phone_number
      t.string :email_address
      t.jsonb :properties

      t.timestamps
    end
  end
end
