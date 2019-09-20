# frozen_string_literal: true

module Ros
  module Cognito
    class Client < Ros::Platform::Client; end
    class Base < Ros::Sdk::Base; end
    class AppPolicy < Ros::Sdk::AppPolicy; end

    class Tenant < Base; end
    class Endpoint < Base; end
    class Pool < Base; end
    class User < Base; end
    class Identifier < Base; end
    class FileFingerprint < Base; end

    class TenantPolicy < AppPolicy; end
    class EndpointPolicy < AppPolicy; end
    class PoolPolicy < AppPolicy; end
    class PoolPolicy < AppPolicy; end
    class UserPolicy < AppPolicy; end
    class IdentifierPolicy < AppPolicy; end
    class FileFingerprintPolicy < AppPolicy; end
  end
end
