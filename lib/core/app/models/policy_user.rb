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
    @iam_user&.attached_actions || {}
  end

  def root?
    ['Root', 'Ros::IAM::Root'].include? @iam_user.class.name
  end
end
