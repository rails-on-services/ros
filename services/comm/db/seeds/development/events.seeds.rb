# frozen_string_literal: true

after 'development:campaigns', 'development:templates', 'development:providers' do
  Tenant.all.each do |tenant|
    next if tenant.id.eql? 1

    tenant.switch do
      template = Template.first
      campaign = Campaign.first
      provider = Provider.first

      FactoryBot.create(:event, provider: provider, campaign: campaign, template: template)
    end
  end
end
