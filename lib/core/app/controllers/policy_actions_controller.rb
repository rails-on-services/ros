# frozen_string_literal: true

class PolicyActionsController < ApplicationController
  def index
    render json: json_resources(resource_class: PolicyActionResource, records: resources)
  end

  private

  def resources
    return [] unless (json = Settings.dig(:service, :policy_actions))
    json.map { |model| PolicyActionResource.new(PolicyAction.new(model), nil) }
  end
end
