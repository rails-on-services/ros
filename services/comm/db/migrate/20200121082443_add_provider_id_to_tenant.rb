# frozen_string_literal: true

class AddProviderIdToTenant < ActiveRecord::Migration[6.0]
  def change
    add_reference :tenants, :provider, foreign_key: true
  end
end
