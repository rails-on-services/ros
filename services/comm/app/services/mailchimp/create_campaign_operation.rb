# frozen_string_literal: true

module Mailchimp
  class CreateCampaignOperation
    attr_reader :campaign
    delegate :type, :subject, :name, :from_name, :from_email, to: :campaign

    def initialize(campaign)
      @campaign = campaign
    end

    def request
      campaign.validate!
      request_hash
    end

    private

    def request_hash
      {
        type: campaign.type,
        recipients: { list_id: list.external_id },
        settings: settings_hash
      }
    end

    def settings_hash
      {
        subject_line: subject || list.subject,
        title: name || list.name,
        from_name: from_name || list.from_name,
        reply_to: from_email || list.from_email
      }
    end

    def list
      @list ||= campaign.audience
    end

  end
end