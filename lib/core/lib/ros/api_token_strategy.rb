# frozen_string_literal: true

module Ros
  class ApiTokenStrategy < Warden::Strategies::Base
    attr_accessor :auth_string, :auth_type, :token, :access_key_id, :secret_access_key, :urn

    def auth_string; @auth_string ||= env['HTTP_AUTHORIZATION'] end

    def auth_type; @auth_type ||= auth_string.split.first.downcase end

    def token; @token ||= auth_string&.split&.last end

    def access_key_id; @access_key_id ||= token.split(':').first end

    def secret_access_key; @secret_access_key ||= token.split(':').last end

    def valid?; token.present? end

    def authenticate!
      user = send("authenticate_#{auth_type}") if auth_type.in? %w(basic bearer)
      return success!(user) if user
      # This is returned to IAM service
      fail!({ errors: [{ status: 401, code: 'unauthorized', title: 'Unauthorized' }] }.to_json)
    end

    def authenticate_basic
      # TODO: Credential.authorization must be an instance variable
      Ros::Sdk::Credential.authorization = auth_string
      return unless credential = Ros::IAM::Credential.where(access_key_id: access_key_id).first
      "Ros::IAM::#{credential.owner_type}".constantize.find(credential.owner_id).first
    # NOTE: Swallow the auth error and return nil which causes user to be nil, which cuases FailureApp to be invoked
    rescue JsonApiClient::Errors::NotAuthorized => e
    end

    def authenticate_bearer
      return unless urn = Urn.from_jwt(token)
      return unless urn.model_name.in? %w(Root User)
      # TODO: Credential.authorization must be an instance variable
      Ros::Sdk::Credential.authorization = auth_string
      "Ros::IAM::#{urn.model_name}".constantize.find_by_urn(urn.resource_id)
    # NOTE: Swallow the auth error and return nil which causes user to be nil, which cuases FailureApp to be invoked
    rescue JsonApiClient::Errors::NotAuthorized => e
    end
  end
end
