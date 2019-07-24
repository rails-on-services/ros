# frozen_string_literal: true

class DeviseMailer < Devise::Mailer
  include Ros::Cognito::Engine.routes.url_helpers
  default template_path: 'devise/mailer'
end