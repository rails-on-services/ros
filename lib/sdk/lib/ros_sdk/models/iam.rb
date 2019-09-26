# frozen_string_literal: true

module Ros
  module IAM
    class Client < Ros::Platform::Client; end
    class Base < Ros::Sdk::Base; end
    class AppPolicy < Ros::Sdk::AppPolicy; end

    class Tenant < Base; end
    class FileFingerprint < Base; end
    class Credential < Base; end
    class User < Base
      def self.find_by_urn(username); where(username: username).first end
    end

    class Root < Base
      def self.find_by_urn(id); find(id) end
    end

    class Group < Base; end
    class Role < Base; end

    # p = IAM::Policy.includes(:actions).find(1)
    # p.map(&:actions).flatten.first
    class Policy < Base; end
    class Action < Base; end
    class ReadAction < Action; end

    class TenantPolicy < AppPolicy; end
    class FileFingerprintPolicy < AppPolicy; end
    class CredentialPolicy < AppPolicy; end
    class UserPolicy < AppPolicy; end
    class RootPolicy < AppPolicy; end
    class GroupPolicy < AppPolicy; end
    class RolePolicy < AppPolicy; end
    class PolicyPolicy < AppPolicy; end
    class ActionPolicy < AppPolicy; end
    class ReadActionPolicy < AppPolicy; end
  end
end
