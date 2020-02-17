class AddEmailCampaigns < ActiveRecord::Migration[6.0]
  def change
    create_table :email_campaigns do |t|
      t.references :campaign
      t.references :audience
      t.string :external_id
      t.string :name
      t.string :type
      t.string :from_name
      t.string :from_email
      t.string :subject
      t.string :preview_text
    end
  end
end
