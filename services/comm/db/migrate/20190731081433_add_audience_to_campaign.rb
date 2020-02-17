class AddAudienceToCampaign < ActiveRecord::Migration[6.0]
  def change
    create_table :audiences do |t|
      t.references :campaign
      t.string :name
      t.string :company_name
      t.string :address
      t.string :city
      t.string :state
      t.string :zip
      t.string :country
      t.string :phone
      t.string :reminder
      t.string :from_name
      t.string :from_email
      t.string :subject
      t.string :language
      t.string :external_id

      t.timestamps
    end
  end
end
