# frozen_string_literal: true

class PolicyUser
  attr_reader :iam_user, :cognito_user_id
  attr_accessor :params

  def initialize(user, cognito_user_id, options = {})
    @iam_user = user
    @cognito_user_id = cognito_user_id
    @params = options[:params]
  end

  def attached_policies
    @iam_user&.attached_policies || {}
  end

  def attached_actions
    @iam_user&.attached_actions || []
  end

  def root?
    @iam_user.class.name.eql? 'Root'
  end

  def schema_name
    Tenant.account_id_to_schema(Ros::Urn.from_urn(iam_user.to_urn).account_id)
  end
end
