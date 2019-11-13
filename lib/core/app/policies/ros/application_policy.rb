# frozen_string_literal: true

module Ros
  class ApplicationPolicy
    attr_reader :user, :record, :action

    def initialize(user, record)
      @user = user
      @record = record
    end

    %i[new index show create update edit destroy].each do |method|
      define_method("#{method}?") { check_action(method) }
    end

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
  end
end
