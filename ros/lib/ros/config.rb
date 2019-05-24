=begin
module Ros
  class Config
    attr_accessor :settings

    def initialize
      self.settings = Settings
    end

    def profiles; settings.profiles end
    def images; settings.images end
    def infra; settings.infra end
    def platform; settings.platform end
    def services; settings.services end
    def compose; settings.compose end
  end
end
=end
