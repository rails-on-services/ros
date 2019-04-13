# frozen_string_literal: true

class Root < Iam::ApplicationRecord
  has_one :tenant
  has_many :credentials, as: :owner
  # has_many :ssh_keys

  def self.find_by_urn(id); find(id) end

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
 #         :jwt_authenticatable, # jwt_revocation_strategy: self
 #         jwt_revocation_strategy: Devise::JWT::RevocationStrategies::Null

  def jwt_payload
    { iss: "#{Ros::Sdk.service_endpoints['iam']}", sub: to_urn, scope: '*' }
  end

  def current_tenant
    tenant
  end

  # def self.find_for_jwt_authentication(warden_conditions)
  #   binding.pry
  #   super
  # end

  # def on_jwt_dispatch(token, payload)
  #   binding.pry
  #   super
  # end
end
