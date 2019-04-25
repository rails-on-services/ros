# frozen_string_literal: true

class CampaignResource < Comm::ApplicationResource
  # Serialize the polymorphic :owner association using the specific fields
  # rather than just :owner since if it is :owner JR will look for the class
  # which could be in a separate service and therefore fails
  attributes :owner_type, :owner_id
end
