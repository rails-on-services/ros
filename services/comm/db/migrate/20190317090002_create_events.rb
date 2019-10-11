# frozen_string_literal: true

class CreateEvents < ActiveRecord::Migration[6.0]
  def change
    create_table :events do |t|
      t.string :name
      t.references :campaign, foreign_key: true
      t.references :template, foreign_key: true
      t.references :target, polymorphic: true
      t.references :owner, polymorphic: true
      t.references :provider, foreign_key: true
      t.string :status, null: false
      t.string :channel
      t.timestamp :send_at

      t.timestamps
    end
  end
end
