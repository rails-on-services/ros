# frozen_string_literal: true

class EndpointResource < Cognito::ApplicationResource
  attributes :url, :properties, :target_type, :target_id

  filter :url

  def custom_links(options)
    uri = URI(options[:serializer].link_builder.self_link(self))
    { target: target_uri(uri) }
  end

  def target_uri(uri)
    service, model = @model.target_type.underscore.split('/')
    case Settings.external_connection.type
    when 'service'
      uri.host = uri.host.gsub(Settings.service.name, service)
      uri.path = ['', model, @model.target_id].join('/')
    when 'path'
      uri.path = ['', service, model, @model.target_id].join('/')
    when 'port'
      # TODO Test for whether service_endpoint is nil
      uri.port = URI(Ros::Sdk.service_endpoints[service]).port
    when 'host'
      uri.host = URI(Ros::Sdk.service_endpoints[service]).host
    end
    uri.to_s
  end

  def fetchable_fields
    super - [:urn]
  end

  # def self.updatable_fields(context)
  #   super - [:full_name]
  # end

  # def self.creatable_fields(context)
  #   super - [:full_name]
  # end
  # def resource; [@model.target_type.underscore.split('/').last, @model.target_id].join('/') end

  # def self.sortable_fields(context)
  #   super(context) - [:body]
  # end
end
