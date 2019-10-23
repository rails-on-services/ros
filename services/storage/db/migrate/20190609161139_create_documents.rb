# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration[6.0]
  def change
    create_table :documents do |t|
      t.integer :transfer_map_id
      t.string :header
      t.string :platform_event_state

      t.timestamps
    end
  end
end
