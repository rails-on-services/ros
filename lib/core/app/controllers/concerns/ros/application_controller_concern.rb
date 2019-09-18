# frozen_string_literal: true

module Ros
  module ApplicationControllerConcern
    extend ActiveSupport::Concern

    included do
      include JSONAPI::ActsAsResourceController

      before_action :set_raven_context, if: -> { Settings.credentials.sentry_dsn }
      before_action :authenticate_it!
      after_action :set_headers!

      def authenticate_it!
        return unless (@current_user = request.env['warden'].authenticate!(:api_token))

        if auth_type.basic?
          @current_jwt = Jwt.new(current_user.jwt_payload)
        elsif auth_type.bearer?
          @current_jwt = Jwt.new(request.env['HTTP_AUTHORIZATION'])
          if (sub_cognito = current_jwt.claims['sub_cognito'])
            @cognito_user_urn = Ros::Urn.new(*sub_cognito.split(':'))
            @cognito_user_id = cognito_user_urn.resource_id
          end
        end
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
        @cognito_user ||= cognito_user_urn ? Ros::Cognito::User.find(cognito_user_urn.resource_id) : nil
      end

      def current_user
        @current_user
      end

      def current_jwt
        @current_jwt
      end

      def auth_type
        @auth_type ||= ActiveSupport::StringInquirer.new(request.env['HTTP_AUTHORIZATION'].split[0].downcase)
      end

      # Next method is for Pundit;
      # inside JSONAPI resources can reference user with context[:user]
      def context
        {
          user: current_user,
          cognito_user_id: cognito_user_id
        }
      end

      # Custom resource serializer:
      # render json: json_resources(resource_class: SomeResource, records: query.all)
      def json_resources(resource_class:, records:, context: nil)
        resource = Array.wrap(records).map { |record| resource_class.new(record, context) }
        serialize_resource(resource_class, resource)
      end

      # Return JSONAPI Error objects on common errors
      # https://jsonapi.org/examples/#error-objects-basics
      rescue_from Pundit::NotAuthorizedError do |_error|
        render(status: :forbidden,
               json: { errors: [{ status: '403', code: :forbidden, title: 'Forbidden' }] })
      end

      # Wrap validation errors with JSONAPI::Exceptions::ValidationErrors for non resource calls
      rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_errors

      # TODO: Will internal errors still be reported to Sentry.io?
      if Rails.env.production?
        rescue_from StandardError do |_error|
          render(status: :internal_server_error,
                 json: { errors: [{ status: '500', code: :internal_server_error, title: 'Internal Server Error' }] })
        end
      end

      # This method is invoked on 404s from application's routes.rb if it extends
      # Ros::Routes and includes 'catch_not_found' at the bottom of the routes.rb file
      def not_found
        render(status: :not_found,
               json: { errors: [{ status: '404', code: :not_found, title: 'Not Found' }] })
        # render jsonapi: nil, code: 404, title: 'Invalid Path', detail: params[:path], status: :not_found
      end

      private

      def handle_validation_errors(e)
        resource = ApplicationResource.new(e.record, nil)
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
    end
  end
end
