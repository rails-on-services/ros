# frozen_string_literal: true

module Ros
  module Comm
    class Client < Ros::Platform::Client; end
    class Base < Ros::Sdk::Base; end

    class Tenant < Base; end

    class Message < Base; end
    class Channel < Base; end
  end
end
