class MoveCampaignIdToCampaignEntityId < ActiveRecord::Migration[6.0]
  def up
    add_column :templates, :campaign_entity_id, :bigint
    Tenant.all.each do |t|
      Template.update_all("campaign_entity_id=campaign_id")
    end
    remove_column :templates, :campaign_id
  end

  def down
    add_column :templates, :campaign_id, :bigint
    Tenant.all.each do |t|
      Template.update_all("campaign_id=campaign_entity_id")
    end
    remove_column :templates, :campaign_entity_id
  end
end
