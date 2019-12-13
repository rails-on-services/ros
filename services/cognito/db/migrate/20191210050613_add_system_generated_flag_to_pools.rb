class AddSystemGeneratedFlagToPools < ActiveRecord::Migration[6.0]
  def change
    add_column :pools, :system_generated, :boolean, null: false, default: false
  end
end
