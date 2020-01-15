# frozen_string_literal: true

module Ros
  module ApplicationControllerConcern
    extend ActiveSupport::Concern

    included do
      include JSONAPI::ActsAsResourceController

      before_action :authenticate_it!
      before_action :set_tenant_context
      before_action :set_raven_context, if: -> { ENV['SENTRY_DSN'] }
      after_action :set_headers!

      def authenticate_it!
        Ros::Sdk::Credential.authorization = request.env['HTTP_AUTHORIZATION']
        return unless (@current_user = request.env['warden'].authenticate!(:api_token))

        if auth_type.eql?('basic')
          @current_jwt = Jwt.new(current_user.jwt_payload)
        elsif auth_type.eql?('bearer')
          @current_jwt = Jwt.new(request.env['HTTP_AUTHORIZATION'])
          if (sub_cognito = current_jwt.claims['sub_cognito'])
            @cognito_user_urn = Ros::Urn.from_urn(sub_cognito)
            @cognito_user_id = cognito_user_urn.resource_id
          end
        end
        @internal_call = current_jwt.claims.key?(:__internal).present?
        # TODO: Credential.authorization must be an instance variable
        current_jwt.add_claims(user: current_user.to_json) unless current_jwt.claims.key?(:user)
        current_jwt.add_claims(__internal: true) unless @internal_call
        Ros::Sdk::Credential.authorization = "Bearer #{current_jwt.encode(:internal)}"
      end

      def set_headers!
        return unless current_jwt

        response.set_header('Authorization', "Bearer #{current_jwt.encode}")
        response.set_header('Access-Control-Expose-Headers', 'Authorization')
      end

      def cognito_user_urn
        @cognito_user_urn
      end

      def cognito_user_id
        @cognito_user_id
      end

      def cognito_user
        @cognito_user ||= set_cognito_user
      end

      # NOTE: Unless this is called on the initial request then only internal services will make this call
      # meaning that if the initial request spawns several internal requests that need the cognito_user object
      # then the call will be made several times rather than just on the initial request
      # TODO: Keep an eye on usage patterns and udpate if necessary
      def set_cognito_user
        return unless cognito_user_urn

        user = Ros::Cognito::User.find(cognito_user_urn.resource_id).first
        current_jwt.add_claims(cognito_user: user.to_json)
        Ros::Sdk::Credential.authorization = "Bearer #{current_jwt.encode(:internal)}"
        # NOTE: Swallow the error and return nil
        # TODO: This should probably be logged as a bug since the user should exist
      rescue JsonApiClient::Errors::NotFound => _e
        nil
      end

      def current_user
        @current_user
      end

      def current_jwt
        @current_jwt
      end

      def auth_type
        @auth_type ||= request.env.fetch('HTTP_AUTHORIZATION', '').split[0]&.downcase
      end

      # Next method is for Pundit;
      # inside JSONAPI resources can reference user with context[:user]
      def context
        { user: ::PolicyUser.new(current_user, cognito_user_id, params: params) }
      end

      # Custom Array resource serializer:
      # render json: json_resources(resource_class: SomeResource, records: query.all)
      def json_resources(resource_class:, records:, context: nil)
        resource = Array.wrap(records).map { |record| resource_class.new(record, context) }
        serialize_resource(resource_class, resource)
      end

      # Custom Single resource serializer:
      # render json: json_resource(resource_class: SomeResource, record: query.first)
      def json_resource(resource_class:, record:, context: nil)
        resource = resource_class.new(record, context)
        serialize_resource(resource_class, resource)
      end

      # TODO: Will internal errors still be reported to Sentry.io?
      if Rails.env.production?
        # Return JSONAPI Error objects on common errors
        # https://jsonapi.org/examples/#error-objects-basics
        rescue_from StandardError do |_error|
          render(status: :internal_server_error,
                 json: { errors: [{ status: '500', code: :internal_server_error, title: 'Internal Server Error' }] })
        end
      end

      # Wrap validation errors with JSONAPI::Exceptions::ValidationErrors for non resource calls
      rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_errors

      # Return JSONAPI Error objects on common errors
      # https://jsonapi.org/examples/#error-objects-basics
      rescue_from Pundit::NotAuthorizedError do |_error|
        render(status: :forbidden,
               json: { errors: [{ status: '403', code: :forbidden, title: 'Forbidden' }] })
      end

      # This method is invoked on 404s from application's routes.rb if it extends
      # Ros::Routes and includes 'catch_not_found' at the bottom of the routes.rb file
      def not_found
        render(status: :not_found,
               json: { errors: [{ status: '404', code: :not_found, title: 'Not Found' }] })
        # render jsonapi: nil, code: 404, title: 'Invalid Path', detail: params[:path], status: :not_found
      end

      private

      def handle_validation_errors(error)
        resource = ApplicationResource.new(error.record, nil)
        handle_exceptions JSONAPI::Exceptions::ValidationErrors.new(resource)
      end

      def jsonapi_params
        params.require(:data).require(:attributes)
      end

      def serialize_resource(klass, resource)
        JSONAPI::ResourceSerializer.new(klass).serialize_to_hash(resource)
      end

      def set_raven_context
        # Raven.user_context(id: session[:current_user_id]) # or anything else in session
        Raven.extra_context(params: params.to_unsafe_h, url: request.url, tenant: Apartment::Tenant.current)
      end

      def set_tenant_context
        request.env['X-TenantSchema'] = Apartment::Tenant.current
        request.env['X-CognitoUserId'] = cognito_user_id
        request.env['X-IAMUserId'] = current_user&.id
      end
    end
  end
end
