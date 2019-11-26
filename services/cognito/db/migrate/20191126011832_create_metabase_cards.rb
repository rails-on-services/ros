# frozen_string_literal: true

class CreateMetabaseCards < ActiveRecord::Migration[6.0]
  def change
    create_table :metabase_cards do |t|
      t.integer :card_id
      t.string :uniq_identifier
      t.timestamps
    end
  end
end
