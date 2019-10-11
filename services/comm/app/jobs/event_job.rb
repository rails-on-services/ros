# frozen_string_literal: true

# TODO: Handle the tenant switch in Ros::ApplicationJob
class EventJob < Comm::ApplicationJob
  queue_as :default

  # MessagesController receives a POST request to create a message (sms) with details of from, to and body
  # After the record is created, a Job is created to send to the destination
  # This means that the correct tenant must be selected by apartment
  # rubocop:disable Metrics/MethodLength
  # rubocop:disable Metrics/AbcSize
  def perform(event, tenant_id)
    tenant = Tenant.find(tenant_id)
    iam_tenant = Ros::IAM::Tenant.where(schema_name: tenant.schema_name).first
    tenant.switch do
      event.process!
      template = event.template
      event.users.each do |user|
        template.properties.user = user
        template.properties.endpoint = tenant.
        begin
          content = template.render
          event.messages.create(provider: event.provider, channel: event.channel, to: user.phone_number, body: content)
        rescue NoMethodError => e
          # TODO: Some kind of 'cloudwatch' event reporting situation
          # so that events are logged that the tenant user can view
          Rails.logger.warn "error rendering template #{e.message}"
          nil
        end
      end
      event.publish!
      Rails.logger.info('performed job')
    end
  end
  # rubocop:enable Metrics/MethodLength
  # rubocop:enable Metrics/AbcSize
end
