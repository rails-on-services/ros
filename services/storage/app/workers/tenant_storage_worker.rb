# frozen_string_literal: true

class TenantStorageWorker
  # rubocop:disable Metrics/AbcSize
  def process_event(event)
    Tenant.find_by(schema_name: event.schema_name).switch do
      if event.type.eql? 'upload'
        next if Upload.find_by(name: event.name, etag: event.etag, size: event.size)

        upload = Upload.create(name: event.name, etag: event.etag, size: event.size)
        enqueue(upload)
      elsif event.type.eql? 'download'
      end
    end
  end
  # rubocop:enable Metrics/AbcSize

  # Now that there is a service and name, put a message on Redis
  # which means to put a platform event in cognito consumer queue that says:
  # storage has a file ready
  # Then Cognito service has to pick it up and know what to do with it
  # What cognito needs is:
  # 1: the path to the file
  # 2: the transfer_map target
  # 3: the column_mapping
  # It then determines the tenant and file type and does whatever it is supposed to do for a file of this type
  def enqueue(upload)
    data = { event: upload.persisted?, data: upload }.to_json
    queue_name = "#{upload.transfer_map.service}_platform_consumer_events".to_sym
    Ros::PlatformConsumerEventJob.set(queue: queue_name).perform_later(data)
  end
end
