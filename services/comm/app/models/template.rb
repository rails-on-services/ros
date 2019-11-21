# frozen_string_literal: true

class Template < Comm::ApplicationRecord
  attr_accessor :properties

  after_initialize :initialize_properties

  def initialize_properties
    self.properties = OpenStruct.new
  end

  # See: https://www.stuartellis.name/articles/erb/
  def render(user, campaign)
    return content if user.nil? || campaign.nil?

    properties.user = user
    properties.campaign = campaign

    final_content = content.dup
    keys_to_replace = content.scan(/\[[A-z0-9]+\]/)
    keys_to_replace.each do |key|
      final_content.gsub!(key, value_for(key))
    end
    final_content
  end

  private

  def key_map
    { 'salutation' => { property: :user, value: :title },
      'userFirstName' => { property: :user, value: :first_name },
      'userLastName' => { property: :user, value: :last_name },
      'userId' => { property: :user, value: :primary_identifier },
      'campaignUrl' => { property: :campaign, value: :base_url } }
  end

  def value_for(key)
    key = key.delete '[]'
    mapped_key = key_map[key]
    return key unless mapped_key

    properties[mapped_key[:property]].send(mapped_key[:value])
  end
end
