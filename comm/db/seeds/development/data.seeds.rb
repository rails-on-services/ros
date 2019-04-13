# frozen_string_literal: true

after 'development:tenants' do
  Tenant.all.each do |tenant|
    # next if tenant.id.eql? 1
    tenant.switch do
      twilio = Provider.create(name: "Marketing Team's Twilio", type: 'Providers::Twilio').tap do |provider|
        break unless ENV['TWILIO_ACCOUNT_SID'] and ENV['TWILIO_AUTH_TOKEN']
        provider.credentials.create(key: 'TWILIO_ACCOUNT_SID', secret: ENV['TWILIO_ACCOUNT_SID'])
        provider.credentials.create(key: 'TWILIO_AUTH_TOKEN', secret: ENV['TWILIO_AUTH_TOKEN'])
      end
      aws = Provider.create(name: "Tech Team's AWS", type: 'Providers::Aws').tap do |provider|
        break unless ENV['AWS_ACCESS_KEY_ID'] and ENV['AWS_SECRET_ACCESS_KEY']
        provider.credentials.create(key: 'AWS_ACCESS_KEY_ID', secret: ENV['AWS_ACCESS_KEY_ID'])
        provider.credentials.create(key: 'AWS_SECRET_ACCESS_KEY', secret: ENV['AWS_SECRET_ACCESS_KEY'])
      end
      Campaign.create(owner_type: 'Perx::Survey::Campaign', cognito_endpoint_id: 2, owner_id: 1).tap do |campaign|
        template = campaign.templates.create(
          content: 'Dear <%= user.title %> <%= user.last_name %>, we are delighted to have you ' \
          'with us. At ABC Corp, we always have your interest at heart and appreciate it if you ' \
          'may complete a 2 minute survey for us to know you better. <%= endpoint.url %>' \
          '/primary_identifier=?<%= user.primary_identifier %> to answer a survey'
        )
        tz = ActiveSupport::TimeZone['Asia/Singapore']
        mgmt = campaign.events.create(target_type: 'Ros::Cognito::Pool', target_id: 1, template: template, provider: twilio,
                               channel: :sms, send_at: 1.minutes.from_now)
        prod = campaign.events.create(target_type: 'Ros::Cognito::Pool', target_id: 2, template: template, provider: twilio,
                               channel: :sms, send_at: tz.parse('2019-03-21 17:00:00'))
        # Send to management team at 10am
        eng = campaign.events.create(target_type: 'Ros::Cognito::Pool', target_id: 3, template: template, provider: twilio,
                               channel: :sms, send_at: tz.parse('2019-03-22 10:30:00'))
        support = campaign.events.create(target_type: 'Ros::Cognito::Pool', target_id: 4, template: template, provider: twilio,
                               channel: :sms, send_at: tz.parse('2019-03-22 16:10:00'))
        sales = campaign.events.create(target_type: 'Ros::Cognito::Pool', target_id: 5, template: template, provider: twilio,
                               channel: :sms, send_at: tz.parse('2019-03-22 16:10:00'))
        pru = campaign.events.create(target_type: 'Ros::Cognito::Pool', target_id: 6, template: template, provider: twilio,
                               channel: :sms, send_at: tz.parse('2019-03-22 16:10:00'))
      end
    end
  end
end
