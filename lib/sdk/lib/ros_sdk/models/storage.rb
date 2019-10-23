# frozen_string_literal: true

module Ros
  module Storage
    class Client < Ros::Platform::Client; end
    class Base < Ros::Sdk::Base; end

    class Tenant < Base; end
    class FileFingerprint < Base; end
    class Document < Base; end
    class Image < Base; end
    class Report < Base; end
  end
end
