# frozen_string_literal: true

class CreateActAsStackTraceable < ActiveRecord::Migration[6.0]
    def change
      create_table :act_as_stack_traceable do |t|
        t.string :resource_type, null: false
        t.integer :resource_id, null: false
        t.string :target_resource, null: false
        t.jsonb :payload, null: false
        t.jsonb :response, null: false
        t.datetime :created_at, null: false
      end
    end
  end
  