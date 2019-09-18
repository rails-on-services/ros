# frozen_string_literal: true

module Ros
  module Comm
    class ApplicationMailer < ActionMailer::Base
      default from: 'from@example.com'
      layout 'mailer'
    end
  end
end
