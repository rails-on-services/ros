# frozen_string_literal: true

class AddChannelsToProvider < ActiveRecord::Migration[6.0]
  def change
    add_column :providers, :channels, :jsonb, null: false, default: []
    add_column :providers, :default_for, :jsonb, null: false, default: []
  end
end
