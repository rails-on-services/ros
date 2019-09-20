# frozen_string_literal: true

module Ros
  module Comm
    class Client < Ros::Platform::Client; end
    class Base < Ros::Sdk::Base; end
    class AppPolicy < Ros::Sdk::AppPolicy; end

    class Tenant < Base; end
    class Message < Base; end
    class Channel < Base; end
    class Event < Base; end
    class Template < Base; end
    class FileFingerprint < Base; end

    class TenantPolicy < AppPolicy; end
    class MessagePolicy < AppPolicy; end
    class ChannelPolicy < AppPolicy; end
    class EventPolicy < AppPolicy; end
    class TemplatePolicy < AppPolicy; end
    class FileFingerprintPolicy < AppPolicy; end
  end
end
