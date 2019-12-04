# frozen_string_literal: true

class ServicePoliciesController < ApplicationController
  def index
    render json: json_resources(resource_class: ServicePolicyResource, records: resources)
  end

  private

  def resources
    return [] unless (json = Settings.dig(:service, :policies))
    json.map { |model| ServicePolicyResource.new(ServicePolicy.new(model), nil) }
  end
end
