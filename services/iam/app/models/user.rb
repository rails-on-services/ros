# frozen_string_literal: true

class User < Iam::ApplicationRecord
  has_many :credentials, as: :owner
  # has_many :ssh_keys
  has_many :user_policies, class_name: 'UserPolicyJoin'
  has_many :policies, through: :user_policies
  has_many :actions, through: :policies

  has_many :user_groups, dependent: :delete_all
  has_many :groups, through: :user_groups
  has_many :group_policies, through: :groups, source: :policies
  has_many :group_actions, through: :groups, source: :actions

  has_many :user_roles
  has_many :roles, through: :user_roles
  has_many :role_policies, through: :roles, source: :policies
  has_many :role_actions, through: :roles, source: :actions

  # TODO: we need to support an empty username when an email is provided
  validates :username, presence: true
  validates :username, uniqueness: true
  # store_accessor :permissions, :authorized_policies, :authorized_actions

  # TODO: validate locales inclusion in list and time_zone in available time zones
  # validates :locale, :time_zone, presence: true

  def self.urn_id
    :username
  end

  # We allow users being created without a password so they can choose one
  # themselves
  #
  # Devise calls this
  def password_required?
    confirmed?
  end

  # Devise calls this
  def password_update!(params)
    update!(password: params[:password]) if params[:password] == params[:password_confirmation]
  end

  # Send an email using ActiveJob. This is used for password resets and
  # when a new users needs to set his initial password
  #
  # Devise calls this
  def send_devise_notification(notification, *args)
    devise_mailer.send(notification, self, *args).deliver_later
  end

  # def action_permitted?(action)
  #   return actions.exists?(id: action.id) || group_actions.exists?(id: action.id)
  # end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         :confirmable,
         :recoverable,
         # :registerable,
         # :rememberable, :validatable,
         # :jwt_authenticatable, # jwt_revocation_strategy: self
         # authentication_keys: [:username],
         authentication_keys: [:username]
  # jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  # TODO: Set scope to the user's policies
  def jwt_payload
    @jwt_payload ||= { iss: Settings.jwt.iss, sub: to_urn }
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
