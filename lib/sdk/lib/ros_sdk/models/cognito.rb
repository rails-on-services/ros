# frozen_string_literal: true

module Ros
  module Cognito
    class Client < Ros::Platform::Client; end
    class Base < Ros::Sdk::Base; end

    class Tenant < Base; end
    class Endpoint < Base; end
    class Pool < Base; end
    class User < Base; end
    class Identifier < Base; end
    class FileFingerprint < Base; end
    class MergeRequest < Base; end
  end
end
