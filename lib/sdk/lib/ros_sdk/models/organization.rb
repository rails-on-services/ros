# frozen_string_literal: true

module Ros
  module Organization
    class Client < Ros::Platform::Client; end
    class Base < Ros::Sdk::Base; end

    class Tenant < Base; end
    class Org < Base; end
    class FileFingerprint < Base; end
  end
end
