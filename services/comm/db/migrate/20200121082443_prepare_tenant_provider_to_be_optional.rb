# frozen_string_literal: true

class PrepareMessageProviderToBeOptional < ActiveRecord::Migration[6.0]
  def change
    add_column :tenants, :provider_id, :integer
    remove_foreign_key :messages, :providers
  end
end
