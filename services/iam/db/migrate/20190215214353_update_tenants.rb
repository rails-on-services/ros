# frozen_string_literal: true

class UpdateTenants < ActiveRecord::Migration[6.0]
  def change
    add_reference :tenants, :root, null: false, foreign_key: true, index: { unique: true }
    add_column :tenants, :alias, :string, null: true, index: { unique: true }
    add_column :tenants, :name, :string
    add_column :tenants, :state, :string
  end
end
