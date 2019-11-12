# frozen_string_literal: true

module Ros
  class ApplicationPolicy
    attr_reader :user, :record, :action

    class << self
      def actions
        descendants.reject { |d| d.name.eql? 'ApplicationPolicy' }.each_with_object([]) do |policy, ary|
          ary.concat(policy.accepted_actions.values.flatten)
        end.uniq
      end

      def policies
        descendants.reject { |d| d.name.eql? 'ApplicationPolicy' }.each_with_object([]) do |policy, ary|
          ary.concat(policy.accepted_policies.values.flatten)
        end.uniq
      end

      def accepted_actions
        {
          index?: [
            "#{policy_name}List#{model_name.pluralize}"
          ],
          create?: [
            "#{policy_name}Create#{model_name}"
          ]
        }
      end

      def policy_name
        Settings.service.policy_name
      end

      def model_name
        name.gsub('Policy', '').to_s
      end
    end

    def initialize(user, record)
      @user = user
      @record = record
    end

    # UserPolicy.new({ policies: ['IamFullAccess'] }, nil).index?
    %i[new index show create update edit destroy].each do |method|
      define_method("#{method}?") { check_action(method) } # or send("#{method}?")
    end

    class Scope
      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        actions = if user.attached_actions.is_a?(String)
                    JSON.parse(user.attached_actions)
                  else
                    JSON.parse(user.attached_actions.to_json)
                  end

        scopes = []

        actions.select { |i| i['effect'] == 'allow' && (i['name'] == user.params['action'] || i['name'] == '*') }.each do |allowed_action|
          allowed_action['resources'].each do |target_resource|
            scopes << allowed_action['segment'] if scope.urn_match?(target_resource)
          end
        end

        scopes.inject(scope) do |current_scope, scope_name|
          current_scope.send(scope_name, user)
        end
      end
    end

    # def self.policies
    #   {
    #     "#{policy_name}FullAccess": {
    #       Effect: 'Allow',
    #       Action: "#{policy_name}:*",
    #       Resource: '*'
    #     },
    #     "#{policy_name}ReadOnlyAccess": {
    #       Effect: 'Allow',
    #       Action: ["#{policy_name}:Get*", "#{policy_name}:List*"],
    #       Resource: '*'
    #     }
    #   }
    # end
    #

    def check_action(action)
      return true if user.root?

      actions = if user.attached_actions.is_a?(String)
                  JSON.parse(user.attached_actions)
                else
                  JSON.parse(user.attached_actions.to_json)
                end

      arr = []

      actions.select { |i| i['effect'] == 'allow' && (i['name'] == action.to_s || i['name'] == '*') }.each do |allowed_action|
        allowed_action['resources'].each do |target_resource|
          arr << record.urn_match?(target_resource)
        end
      end

      arr.any?

      # user_policies = user.attached_policies
      # user_actions = user.attached_actions

      # (user_policies.keys & accepted_policies(action)).any? ||
      #   (user_actions.keys & accepted_actions(action)).any?
    end

    def accepted_policies(action)
      self.class.accepted_policies[action] || []
    end

    def accepted_actions(action)
      self.class.accepted_actions[action] || []
    end

    def self.accepted_policies
      {
        index?: [
          'AdministratorAccess',
          "#{policy_name}FullAccess",
          "#{policy_name}ReadOnlyAccess"
        ],
        show?: [
          'AdministratorAccess',
          "#{policy_name}FullAccess",
          "#{policy_name}ReadOnlyAccess"
        ],
        create?: [
          'AdministratorAccess',
          "#{policy_name}FullAccess"
        ],
        update?: [
          'AdministratorAccess',
          "#{policy_name}FullAccess"
        ],
        destroy?: [
          'AdministratorAccess',
          "#{policy_name}FullAccess"
        ]
      }
    end
  end
end
