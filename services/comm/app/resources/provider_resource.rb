# frozen_string_literal: true

class ProviderResource < Comm::ApplicationResource
  attributes :name
end

class TwilioResource < ProviderResource; end
