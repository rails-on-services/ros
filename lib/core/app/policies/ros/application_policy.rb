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

      def policy_name; Settings.service.policy_name end

      def model_name
        name.gsub('Policy', '').to_s
      end
    end

    def initialize(user, record)
      @user = user
      @record = record
    end

    # UserPolicy.new({ policies: ['IamFullAccess'] }, nil).index?
    def index?
      check_action(:index?)
    end

    def show?
      check_action(:show?)
    end

    def create?
      check_action(:create?)
    end

    def new?
      create?
    end

    def update?
      check_action(:update?)
    end

    def edit?
      update?
    end

    def destroy?
      check_action(:destroy?)
    end

    class Scope
      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        scope.all
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
      return true if user.class.name.eql? 'Root'

      (user.attached_policies.keys & accepted_policies(action)).any? ||
        (user.attached_actions.keys & accepted_actions(action)).any?
    end

    def accepted_policies(action); self.class.accepted_policies[action] || [] end

    def accepted_actions(action); self.class.accepted_actions[action] || [] end

    def self.accepted_policies
      {
        index?: [
          'AdministratorAccess',
          "#{policy_name}FullAccess",
          "#{policy_name}ReadOnlyAccess"
        ],
        show?: [
          'AdministratorAccess',
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
