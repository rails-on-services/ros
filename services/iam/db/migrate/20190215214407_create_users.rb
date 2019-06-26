# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  # rubocop:disable Metrics/MethodLength
  def change
    create_table :users do |t|
      t.boolean :console, null: false, default: false, comment: 'Allow console access when true'
      t.boolean :api, null: false, default: false, comment: 'Allow API access when true'
      t.string :time_zone, null: false, default: 'UTC', comment: 'Adjust timestamps to this time zone'
      t.jsonb :attached_policies, null: false, default: {}
      t.jsonb :attached_actions, null: false, default: {}
      t.jsonb :properties, null: false, default: {}, comment: 'Custom properties of the user'
      t.jsonb :display_properties, null: false, default: {}, comment: 'Custom display properties of the user'

      ## Database authenticatable
      t.string :username, null: false, index: { unique: true }
      t.string :encrypted_password, null: false, default: '', comment: 'Required if console is true'

      ## Recoverable
      t.string   :reset_password_token, index: { unique: true }
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## Confirmable
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      t.timestamps null: false
    end
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true
  end
  # rubocop:enable Metrics/MethodLength
end
