class AddProviderIdToMessage < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :provider_msg_id, :string
  end
end
