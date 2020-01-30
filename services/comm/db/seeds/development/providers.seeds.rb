# frozen_string_literal: true

after 'development:tenants' do
  Tenant.all.each do |tenant|
    tenant.switch do
      Providers::Twilio.create(name: "Marketing Team's Twilio", account_sid: ENV['TWILIO_ACCOUNT_SID'],
                               auth_token: ENV['TWILIO_AUTH_TOKEN'], channels: %w[sms call])
      Providers::Aws.create(name: "Tech Team's AWS", access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                            secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], channels: ['sms'])
    end
  end
end
