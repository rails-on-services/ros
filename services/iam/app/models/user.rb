# frozen_string_literal: true

class User < Iam::ApplicationRecord
  has_many :credentials, as: :owner
  # has_many :ssh_keys
  has_many :user_policies, class_name: 'UserPolicyJoin'
  has_many :policies, through: :user_policies
  has_many :actions, through: :policies

  has_many :user_groups
  has_many :groups, through: :user_groups
  has_many :group_policies, through: :groups, source: :policies
  has_many :group_actions, through: :groups, source: :actions

  has_many :user_roles
  has_many :roles, through: :user_roles
  has_many :role_policies, through: :roles, source: :policies
  has_many :role_actions, through: :roles, source: :actions

  validates :username, presence: true
  # store_accessor :permissions, :authorized_policies, :authorized_actions

  # TODO: validate locales inclusion in list and time_zone in available time zones
  # validates :locale, :time_zone, presence: true

  def self.urn_id; :username end

  # def action_permitted?(action)
  #   return actions.exists?(id: action.id) || group_actions.exists?(id: action.id)
  # end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
      # :registerable,
      # :recoverable, :rememberable, :validatable,
  #    :jwt_authenticatable, # jwt_revocation_strategy: self
  #     authentication_keys: [:username],
      authentication_keys: [:username]
  #    jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  # TODO: Set scope to the user's policies
  def jwt_payload
    { iss: "#{Ros::Sdk.service_endpoints['iam']}", sub: to_urn, scope: '*' }
  end

  # NOTE: Credential is in the public schema
  # It seems that has_many :credentials, through: :user_credentials
  # does not work properly from a tenant to the public schema
  # So credentials is implemented here
  # NOTE: In order to create a credential, normally you would do:
  # credentials.create
  # whereas do to the above it is:
  # user_credentials.create
  # def credentials
  #   Credential.where(id: user_credentials.pluck(:credential_id))
  # end

  # def self.find_for_jwt_authentication(warden_conditions)
  #   binding.pry
  #   super
  # end

  # def on_jwt_dispatch(token, payload)
  #   binding.pry
  #   super
  # end
end
