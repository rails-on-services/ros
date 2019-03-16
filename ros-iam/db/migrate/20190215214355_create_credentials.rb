# frozen_string_literal: true

class CreateCredentials < ActiveRecord::Migration[6.0]
  def change
    create_table :credentials do |t|
      # t.references :tenant, foreign_key: true
      # t.string :type

      t.references :owner, polymorphic: true
      t.string :access_key_id, length: 20
      # t.string :secret_access_key
      t.string :secret_access_key_digest

      t.timestamps
    end
    add_index :credentials, :access_key_id, unique: true
  end
end
