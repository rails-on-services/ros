# frozen_string_literal: true

module Ros
  module TenantConcern
    extend ActiveSupport::Concern

    class_methods do
      def urn_id; :account_id end

      def schema_name_for(id:)
        Tenant.find_by(id: id)&.schema_name
      end

      def schema_name_from(account_id: nil, id: nil)
        if account_id && (tenant = Tenant.find_by(schema_name: account_id_to_schema(account_id)))
          tenant.schema_name
        elsif id && (tenant = Tenant.find_by(id: id))
          tenant.schema_name
        end
      end

      def account_id_to_schema(account_id)
        return 'public' if account_id.to_i.zero?

        account_id.to_s.scan(/.{3}/).join('_')
      end

      def find_by_schema_or_alias(criterion)
        where('schema_name = ? OR alias = ?',
              account_id_to_schema(criterion),
              criterion).first
      end
    end

    included do
      attr_reader :account_id

      validates :schema_name, presence: true

      validates :schema_name, length: { is: 11 }, unless: proc { |record| record.schema_name.eql?('public') }

      validate :fixed_values_unchanged, if: :persisted?

      after_commit :create_schema, on: :create, unless: proc { |record| record.schema_name.eql?('public') }

      after_commit :destroy_schema, on: :destroy, unless: proc { |record| record.schema_name.eql?('public') }

      def fixed_values_unchanged
        errors.add(:schema_name, 'schema_name cannot be changed') if schema_name_changed?
      end

      def account_id
        @account_id ||= schema_name.to_i
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

      def to_urn; "#{self.class.urn_base}:0:tenant/#{id}" end

      # TODO: Create IAM Roles in the public schema
      def set_role_credential(type = 'user', uid = 'Admin', policies = {}, actions = {})
        jwt = role_jwt(type.downcase, uid, policies, actions)
        Ros::Sdk::Credential.authorization = "Bearer #{jwt.encode(:internal)}"
      end

      def role_jwt(type, uid, policies, actions)
        urn = "#{self.class.urn_base}:#{account_id}:#{type}/#{uid}"
        attrs = { id: 1, sub: urn, attached_policies: policies, attached_actions: actions }
        user = "Ros::IAM::#{type.camelize}".constantize.new(attrs)
        Ros::Jwt.new(sub: urn, user: user.to_json)
      end

      def clear_credential; Ros::Sdk::Credential.authorization = nil end

      def create_schema
        Apartment::Tenant.create(schema_name)
        Rails.logger.info("Tenant created: #{schema_name}")
      rescue Apartment::TenantExists => e
        Rails.logger.warn("Failed to create tenant (already exists): #{schema_name}")
        raise e if Rails.env.production? # Don't raise an exception in dev mode so to allow seeds to work
      end

      # NOTE: This is only called when tenant#destroy is called NOT tenant#delete
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
