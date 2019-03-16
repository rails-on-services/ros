# frozen_string_literal: true

class UserPolicy < Iam::ApplicationPolicy; end

=begin
  # def index?
  #   user.action_permitted?(requested_action(__method__))
  #   # user.admin? || !record.published?
  # end

  def self.zactions
    {
      Write: [
        'AddUserToGroup'
      ]
    }
  end

  def update?
    super
    # does current_user have permission 'UpdateUser'
  end

  # NOTE: Iam is a class in the api-client as are all namespaced models
  #requested_action = Iam::Service.find_by(name: 'User').actions.find_by(name: 'DescribeUser')
  # NOTE: The result should be cached as this value will not change frequently
  # NOTE: There should be a way to break the cache in case the value does change
  def requested_action(method_name)
    Service.find_by(name: service_name).actions.find_by(name: action_name(method_name))
  end

  def action_name(method_name)
    method_map[method_name] + service_name
  end
=end
