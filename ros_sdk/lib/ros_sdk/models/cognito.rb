# frozen_string_literal: true

module Ros
  module Cognito
    class Client < Ros::Platform::Client; end
    class Base < Ros::Sdk::Base; end

    class Tenant < Base; end
    class Endpoint < Base; end
  end
end
