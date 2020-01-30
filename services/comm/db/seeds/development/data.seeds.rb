# frozen_string_literal: true

after 'development:tenants' do
  Tenant.all.each do |tenant|
    # next if tenant.id.eql? 1
    tenant.switch do
      if tenant.schema_name == 'public'
        Providers::Twilio.create(name: "Marketing Team's Twilio", account_sid: ENV['TWILIO_ACCOUNT_SID'],
                                 auth_token: ENV['TWILIO_AUTH_TOKEN'], channels: %w[sms call])
        Providers::Aws.create(name: "Tech Team's AWS", access_key_id: ENV['AWS_ACCESS_KEY_ID'],
                              secret_access_key: ENV['AWS_SECRET_ACCESS_KEY'], channels: ['sms'])
      end
      # Campaign.create(owner_type: 'Perx::Survey::Campaign', cognito_endpoint_id: 2, owner_id: 1).tap do |campaign|
      #   template = campaign.templates.create(
      #     content: 'Dear <%= user.title %> <%= user.last_name %>, we are delighted to have you ' \
      #     'with us. At ABC Corp, we always have your interest at heart and appreciate it if you ' \
      #     'may complete a 2 minute survey for us to know you better. <%= endpoint.url %>' \
      #     '/primary_identifier=?<%= user.primary_identifier %> to answer a survey'
      #   )
      #   tz = ActiveSupport::TimeZone['Asia/Singapore']
      #   mgmt = campaign.events.create(target_type: 'Ros::Cognito::Pool', target_id: 1, template: template,
      #                                 provider: twilio, channel: :sms, send_at: 1.minutes.from_now)
      #   prod = campaign.events.create(target_type: 'Ros::Cognito::Pool', target_id: 2, template: template,
      #                                 provider: twilio, channel: :sms, send_at: tz.parse('2019-03-21 17:00:00'))
      #   # Send to management team at 10am
      #   eng = campaign.events.create(target_type: 'Ros::Cognito::Pool', target_id: 3, template: template,
      #                                provider: twilio, channel: :sms, send_at: tz.parse('2019-03-22 10:30:00'))
      #   support = campaign.events.create(target_type: 'Ros::Cognito::Pool', target_id: 4, template: template,
      #                                    provider: twilio, channel: :sms, send_at: tz.parse('2019-03-22 16:10:00'))
      #   sales = campaign.events.create(target_type: 'Ros::Cognito::Pool', target_id: 5, template: template,
      #                                  provider: twilio, channel: :sms, send_at: tz.parse('2019-03-22 16:10:00'))
      #   pru = campaign.events.create(target_type: 'Ros::Cognito::Pool', target_id: 6, template: template,
      #                                provider: twilio, channel: :sms, send_at: tz.parse('2019-03-22 16:10:00'))
      # end
    end
  end
end
