# frozen_string_literal: true

module Ros
  class ApiTokenStrategy < Warden::Strategies::Base
    attr_accessor :auth_string, :auth_type, :token, :access_key_id, :secret_access_key, :access_key

    # rubocop:disable Lint/DuplicateMethods
    def auth_string; @auth_string ||= env['HTTP_AUTHORIZATION'] end

    def auth_type; @auth_type ||= auth_string.split.first.downcase end

    def token; @token ||= auth_string&.split&.last end

    def access_key_id; @access_key_id ||= token.split(':').first end

    def access_key; @access_key ||= Ros::AccessKey.decode(access_key_id) end

    def secret_access_key; @secret_access_key ||= token.split(':').last end
    # rubocop:enable Lint/DuplicateMethods

    def valid?; token.present? end

    def authenticate!
      user = send("authenticate_#{auth_type}") if auth_type.in? %w[basic bearer]
      return success!(user) if user

      # This is returned to IAM service
      fail!({ errors: [{ status: 401, code: 'unauthorized', title: 'Unauthorized' }] }.to_json)
    end

    # TODO: Credential.authorization must be an instance variable
    def authenticate_basic
      return unless access_key[:version].positive?

      "Ros::IAM::#{access_key[:owner_type]}".constantize.find(access_key[:owner_id]).first
    # NOTE: Swallow the auth error and return nil which causes user to be nil, which cuases FailureApp to be invoked
    rescue JsonApiClient::Errors::NotAuthorized
      nil
    end

    def authenticate_bearer
      return unless (jwt = Ros::Jwt.new(token))

      return unless (urn = Urn.from_urn(jwt.claims['sub']))

      # return unless urn.model_name.in? %w[Root User]

      if jwt.claims.key?('user')
        "Ros::IAM::#{urn.model_name}".constantize.new(JSON.parse(jwt.claims['user']))
      else
        # rubocop:disable Rails/DynamicFindBy
        "Ros::IAM::#{urn.model_name}".constantize.find_by_urn(urn.resource_id).first
        # rubocop:enable Rails/DynamicFindBy
      end

    # NOTE: Swallow the auth error and return nil which causes user to be nil, which cuases FailureApp to be invoked
    rescue JsonApiClient::Errors::NotAuthorized
      nil
    end
  end
end
