# frozen_string_literal: true

class WhatsappResource < Comm::ApplicationResource
  attributes :body, :to, :from
end
