class CreateWhatsapps < ActiveRecord::Migration[6.0]
  def change
    create_table :whatsapps do |t|
      t.string :sms_message_sid
      t.string :num_media
      t.string :sms_sid
      t.string :sms_status
      t.string :body
      t.string :to
      t.string :num_segments
      t.string :message_sid
      t.string :account_sid
      t.string :from
      t.string :api_version

      t.timestamps
    end
  end
end
