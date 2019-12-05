# frozen_string_literal: true

module Ros
  module TenantConcern
    extend ActiveSupport::Concern

    class_methods do
      def urn_id; :account_id end

      def find_by_schema_or_alias(criterion)
        find_by('schema_name = ? OR alias = ?', account_id_to_schema(criterion), criterion.to_s)
      end

      def schema_name_from(account_id: nil, id: nil)
        return unless account_id || id

        criterion = account_id ? { schema_name: account_id_to_schema(account_id) } : { id: id }
        find_by(criterion)&.schema_name
      end

      def account_id_to_schema(account_id)
        %w[public 0].include?(account_id.to_s) ? 'public' : account_id.to_s.scan(/.{3}/).join('_')
        # account_id.to_i.zero? ? 'public' : account_id.to_s.scan(/.{3}/).join('_')
      end
    end

    included do
      attr_reader :account_id

      validates :schema_name, presence: true

      validates :schema_name, length: { is: 11 }, unless: proc { |record| record.schema_name.eql?('public') }

      validate :fixed_values_unchanged, if: :persisted?

      after_commit :create_schema, on: :create

      after_commit :destroy_schema, on: :destroy

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

      # All tenants belong to the platform owner (public schema with account_id 0)
      def to_urn; "#{self.class.urn_base}:0:tenant/#{account_id}" end

      # TODO: Create IAM Roles in the public schema
      # rubocop:disable Naming/AccessorMethodName
      def set_role_credential(opts = { user: 'Admin' })
        jwt = jwt_for_role(opts)
        Ros::Sdk::Credential.authorization = "Bearer #{jwt.encode(:internal)}"
      end
      # rubocop:enable Naming/AccessorMethodName

      def clear_credential; Ros::Sdk::Credential.authorization = nil end

      def create_schema
        return if schema_name.eql?('public')

        Apartment::Tenant.create(schema_name)
        Rails.logger.info("Tenant created: #{schema_name}")
      rescue Apartment::TenantExists => e
        Rails.logger.warn("Failed to create tenant (already exists): #{schema_name}")
        raise e if Rails.env.production? # Don't raise an exception in dev mode so to allow seeds to work
      end

      # NOTE: This is only called when tenant#destroy is called NOT tenant#delete
      def destroy_schema
        return if schema_name.eql?('public')

        Apartment::Tenant.drop(schema_name)
        Rails.logger.info("Tenant dropped: #{schema_name}")
      rescue Apartment::TenantNotFound => e
        Rails.logger.warn("Failed to drop tenant (not found): #{schema_name}")
        raise e if Rails.env.production? # Don't raise an exception in dev mode so to allow seeds to work
      end

      private

      def jwt_for_role(opts)
        type = opts.keys.first.to_s
        uid = opts.values.first
        urn = "#{self.class.urn_base}:#{account_id}:#{type}/#{uid}"
        attrs = { id: 1, sub: urn, attached_policies: {}, attached_actions: {} }
        user = "Ros::IAM::#{type.camelize}".constantize.new(attrs)
        # if the user is root then return a Jwt that doesn't require authentiation by supplying the user attribute
        hash = type.eql?('user') ? { sub: urn } : { sub: urn, user: user.to_json }
        Ros::Jwt.new(hash)
      end
    end
  end
end
