class CreateCampaigns < ActiveRecord::Migration[6.0]
  def change
    create_table :campaigns do |t|
      t.string :name
      t.string :description
      t.references :owner, polymorphic: true
      t.integer :cognito_endpoint_id

      t.timestamps
    end
  end
end
