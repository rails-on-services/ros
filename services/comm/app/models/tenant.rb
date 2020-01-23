# frozen_string_literal: true

class Tenant < Comm::ApplicationRecord
  include Ros::TenantConcern

  store_accessor :platform_properties, :platform_twilio_enabled, :platform_aws_enabled

  def default_provider_for(channel)
    # NOTE: Named bunding used here to be able to use operator `?` from postgres
    Provider.find_by('default_for ? :channel', channel: channel)
  end
end
