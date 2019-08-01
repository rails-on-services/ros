# frozen_string_literal: true

module MailchimpService

  class Client
    def self.perform(&block)
      client = Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY'], symbolize_keys: true, debug: true)
      result = block.call(client)
      OpenStruct.new(result.body)
    rescue Gibbon::MailChimpError => e
      parse_error(e)
    rescue ActiveRecord::RecordInvalid => e
      e.record
    end

    def self.parse_error(e)
      return e if e.body.nil?

      body = e.body
      unless body[:errors]
        body[:errors] = {
          message: body[:title],
          status: body[:status]
        }
      end
      OpenStruct.new(errors: body[:errors])
    end
  end

  # show list members
  def show_members(list:)
    Client.perform do |client|
      client.lists(list.external_id).members.retrieve
    end
  end

  # add members to list
  def create_members(list:, members:)
    operation = Mailchimp::CreateMembersOperation.new(list_id: list.external_id, members: members)
    Client.perform do |client|
      client.batches.create body: { operations: operation.request }
    end
  end

  # create new list with members
  def create_list(list:)
    Client.perform do |client|
      operation = Mailchimp::CreateListOperation.new(list)
      client.lists.create(body: operation.request)
    end
  end

  # Create campaign
  def create_campaign(campaign:)
    Client.perform do |client|
      operation = Mailchimp::CreateCampaignOperation.new(campaign)
      client.campaigns.create(body: operation.request)
    end
  end

  # Campaign checklist
  def campaign_status(campaign:)
    Client.perform do |client|
      client.campaigns(campaign.external_id).send_checklist.retrieve
    end
  end

  # Show campaign template
  def show_campaign_content(campaign:)
    Client.perform do |client|
      client.campaigns(campaign.external_id).content.retrieve
    end
  end

  # Create Campaign template
  def create_campaign_content(campaign:, raw_html:)
    Client.perform do |client|
      client.campaigns(campaign.external_id).content.upsert(body: { html: raw_html })
    end
  end

  # Send email
  def start_campaign(campaign:)
    Client.perform do |client|
      client.campaign(campaign.external_id).send.create
    end
  end

  module_function :show_members, :create_members, :create_list, :create_campaign,
                  :campaign_status, :show_campaign_content, :create_campaign_content, :start_campaign

end