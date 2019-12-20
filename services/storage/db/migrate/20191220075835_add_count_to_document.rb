# frozen_string_literal: true

class AddCountToDocument < ActiveRecord::Migration[6.0]
  def change
    add_column :documents, :status, :string
    add_column :documents, :processed_amount, :integer
    add_column :documents, :success_amount, :integer
    add_column :documents, :fail_amount, :integer
    add_column :documents, :processed_details, :jsonb
  end
end
