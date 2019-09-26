# frozen_string_literal: true

module Ros
  module Storage
    class Client < Ros::Platform::Client; end
    class Base < Ros::Sdk::Base; end
    class AppPolicy < Ros::Sdk::AppPolicy; end

    class Tenant < Base; end
    class FileFingerprint < Base; end

    class TenantPolicy < AppPolicy; end
    class FileFingerprintPolicy < AppPolicy; end
  end
end
