# frozen_string_literal: true

class User < Iam::ApplicationRecord
  has_many :credentials, as: :owner
  has_many :public_keys

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

  validates :username, presence: true
  validates :username, uniqueness: true
  # store_accessor :permissions, :authorized_policies, :authorized_actions

  # TODO: validate locales inclusion in list and time_zone in available time zones
  # validates :locale, :time_zone, presence: true

  def self.urn_id; :username end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable,
         # :registerable,
         # :recoverable, :rememberable, :validatable,
         # :jwt_authenticatable, # jwt_revocation_strategy: self
         # authentication_keys: [:username],
         authentication_keys: [:username]
  # jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  scope :owned, ->(user_context) { where(id: user_context.iam_user.id) }

  def all_policy_actions
    # delete duplication and group by name, effect and segment
    merged = (actions + group_actions + role_actions).uniq.group_by do |i|
      { name: i.name, effect: i.effect, segment: i.segment }
    end

    # convert to neat format
    merged.map do |k, v|
      # shrink overlaping resources
      resources = v.map(&:target_resource)
      k.merge(resources: shrink_resources(resources))
    end
  end

  def jwt_payload; @jwt_payload ||= { sub: to_urn } end

  def recalculate_attached_actions
    update(attached_actions: all_policy_actions)
  end

  private

  def shrink_resources(resources)
    arr = []
    resources.each do |resource|
      added = false
      arr.each do |item|
        added = true if item == resource
      end
      arr << resource unless added
    end
    arr
  end
end
