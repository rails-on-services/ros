# frozen_string_literal: true

module Ros
  module IAM
    class Client < Ros::Platform::Client; end
    class Base < Ros::Sdk::Base; end
    class AppPolicy < Ros::Sdk::AppPolicy; end

    class Tenant < Base; end
    class FileFingerprint < Base; end
    class Credential < Base; end
    class User < Base
      def self.find_by_urn(username); where(username: username).first end
      # app.post '/users/sign_in', { user: { username: 'email@test1.com', password: 'abcd1234' }}
      # Ros::IAM::User.sign_in(user: { username: 'Fred', password: 'abcd1234' }, account_id: '806470858')
      # custom_endpoint :sign_in, on: :collection, request_method: :post
    end

    class Root < Base
      def self.find_by_urn(id); find(id) end
      # TODO: Return a JWT and capture it in the middleware
      # custom_endpoint :sign_in, on: :collection, request_method: :post
    end

    class Group < Base; end
    class Role < Base; end

    # p = IAM::Policy.includes(:actions).find(1)
    # p.map(&:actions).flatten.first
    class Policy < Base; end
    class Action < Base; end
    class ReadAction < Action; end

    class TenantPolicy < AppPolicy; end
    class FileFingerprintPolicy < AppPolicy; end
    class CredentialPolicy < AppPolicy; end
    class UserPolicy < AppPolicy; end
    class RootPolicy < AppPolicy; end
    class GroupPolicy < AppPolicy; end
    class RolePolicy < AppPolicy; end
    class PolicyPolicy < AppPolicy; end
    class ActionPolicy < AppPolicy; end
    class ReadActionPolicy < AppPolicy; end
  end
end

=begin
      class Account < Base
        def self.table_name; 'user_accounts' end
      end

      class Tenant < Base
        def self.table_name; 'user_tenants' end
      end

      class Role< Base
        def self.table_name; 'user_roles' end
      end

module ApiV0
  module User
    class Base < ApiV1::Base
      uses_api Internal::ApiV1.servers['user']
    end

    class Account < Base
      collection_path 'internal/api_v1/user_accounts'
      type :user_accounts
      attributes :email, :first_name, :last_name
      api_has_many :device_accounts, class_name: 'ApiV1::Device::Account', foreign_key: :user_account_id

      #
      # Convenience method which returns list of accounts in whichever service this user object was instantiated in
      #
      def accounts
        ENV['APPLICATION_NAME'].classify.constantize::Account.where(user_account_id: id)
      end

      #
      # Convenience method which returns list of transactions in whichever service this user object was instantiated in
      #
      def transactions
        account_where = Hash["#{Rails.application.class.parent.name.underscore}_accounts", { user_account_id: id }]
        ENV['APPLICATION_NAME'].classify.constantize::Transaction.joins(:account).where(account_where)
      end

      def roles
        AccountRole.xwhere(user_account_id: id).results
      end

      # NOTE: This is a very inefficient method. It makes two additional API calls and result is calculated on client
      # TODO: Refactor so that it is a single API call #has_role that returns a boolean from User service
      def has_role?(role_name)
        return false unless (role_id = Role.find_by(name: role_name).try(:id).try(:to_i))
        roles.select { |role| role.user_role_id.eql? role_id }.size > 0
      end
    end

    class AccountRole < Base
      collection_path 'internal/api_v1/user_account_roles'
      type :user_account_roles
    end

    class Action < Base
      collection_path 'internal/api_v1/user_actions'
      type :user_actions
    end

    class ActionTransaction < Base
      collection_path 'internal/api_v1/user_action_transactions'
      type :user_action_transactions
    end

    class Group < Base
      collection_path 'internal/api_v1/user_groups'
      type :user_groups
    end

    class GroupAccount < Base
      collection_path 'internal/api_v1/user_group_accounts'
      type :user_group_accounts

      def self.import_user_tokens(uploaded_files)
        uploaded_files.each do |info|
          ApiV1::User::Group.create(name: info[:list_name], list_file_url: info[:list_file_url])
        end
      end
    end

    class MembershipAccount < Base
      collection_path 'internal/api_v1/user_membership_accounts'
      type :membership_accounts
    end

    class Notification < Base
      collection_path 'internal/api_v1/user_notifications'
      type :user_notifications
    end

    class Role < Base
      collection_path 'internal/api_v1/user_roles'
      type :user_roles
    end

    class Tagging < Base
      collection_path 'internal/api_v1/user_taggings'
      type :user_taggings
    end

    class Tenant < Base
      collection_path 'internal/api_v1/user_tenants'
      type :user_tenants
    end

    class Transaction < Base
      collection_path 'internal/api_v1/user_transactions'
      type :user_transactions
      belongs_to :account, class_name: 'ApiV1::User::Account'
    end
  end
end
=end
