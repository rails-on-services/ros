# frozen_string_literal: true

module Ros
  module TenantConcern
    extend ActiveSupport::Concern
  
    class_methods do
      def excluded_models
        %w(Tenant)
      end

      def urn_id; :account_id end
  
      def public_schema_endpoints; [] end
  
      def schema_name_for(id:)
        Tenant.find_by(id: id)&.schema_name || public_schema
      end
  
      def schema_name_from(account_id: nil, id: nil)
        if account_id and (tenant = Tenant.find_by(schema_name: account_id_to_schema(account_id)))
          return tenant.schema_name
        elsif id and (tenant = Tenant.find_by(id: id))
          return tenant.schema_name
        end
      end

      def account_id_to_schema(account_id) 
        account_id.to_s.scan(/.{3}/).join('_')
      end
  
      def public_schema
        case ActiveRecord::Base.connection.class.name
        when 'ActiveRecord::ConnectionAdapters::SQLite3Adapter'
          nil
        when 'ActiveRecord::ConnectionAdapters::PostgreSQLAdapter'
          'public'
        end
      end
    end
  
    included do
      attr_reader :account_id

      validates :schema_name, presence: true, length: { is: 11 }

      validate :fixed_values_unchanged, if: :persisted?
  
      after_create :create_schema
  
      after_destroy :destroy_schema

      def fixed_values_unchanged
        errors.add(:schema_name, 'schema_name cannot be changed') if schema_name_changed?
      end

      def account_id
        @account_id ||= schema_name.remove('_')
      end

      def current_tenant
        self
      end

      def switch!
        Apartment::Tenant.switch!(schema_name)
      end

      def switch
        Apartment::Tenant.switch(schema_name) do
          yield
        end
      end

      # NOTE: *** WARNING ***
      # These next three methods are only for use in the console in development mode
      # DO NOT use these methods to set/use credentials in request handling!
      def set_root_credential; set_user_credential(root_id, 'root') end

      def set_user_credential(uid = nil, type = 'user')
        return unless Rails.env.development?
        Ros::Sdk::Credential.authorization = Settings.tenant[id].try(:[], type).try(:[], uid)
      end

      def clear_credential; Ros::Sdk::Credential.authorization = nil end
  
      # NOTE: This method is very important!
      # Called by RpcWorker#receive and TenantMiddleware#parse_tenant_name
      # It parses a request hash and sets the necessary RequestStere settings
      # The caller then uses these settings to select the appropriate schema for the request to operate on
      # TODO: This is probably where the JWT will be processed; Or it will already be decrypted and values put into the header
      # NOTE: Either way, the request header needs to put the tenant somewhere so logging can be done per tenant
      # NOTE: This method does not current work. it is code ported from another project
      def self.set_request_store(request_hash)
        request = RequestStore.store[:tenant_request] = ApiAll::TenantRequest.new(request_hash)
        raise ArgumentError, 'Tenant schema is nil!' unless request.schema_name
        RequestStore.store[:tenant] = find_by!(schema_name: request.schema_name)
      end
  
      def create_schema
        Apartment::Tenant.create(schema_name)
        Rails.logger.info("Tenant created: #{schema_name}")
      rescue Apartment::TenantExists => e
        Rails.logger.warn("Failed to create tenant (already exists): #{schema_name}")
        raise e if Rails.env.production? # Don't raise an exception in dev mode so to allow seeds to work
      end
  
      def destroy_schema
        Apartment::Tenant.drop(schema_name)
        Rails.logger.info("Tenant dropped: #{schema_name}")
      rescue Apartment::TenantNotFound => e
        Rails.logger.warn("Failed to drop tenant (not found): #{schema_name}")
        raise e if Rails.env.production? # Don't raise an exception in dev mode so to allow seeds to work
      end
    end
  end
end
