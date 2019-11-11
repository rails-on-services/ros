# frozen_string_literal: true

class Document < Storage::ApplicationRecord
  include HasAttachment

  belongs_to :transfer_map, optional: true

  def self.object_dir; 'uploads' end

  def self.blob_key(_owner, blob)
    blob.filename
  end

  # Takes array of events from SQS worker with keys to attached files. For each event/file it:
  # creates an A/S blob and a Document record to attach the blob to
  # It then downloads the blob, extracts the header and calls identify_transfer_map
  def self.attach_from_storage_events(events)
    events.each do |event|
      Rails.logger.debug { "Document received event #{event}" }
      if event.type.eql?('created') && event.size.positive?
        Rails.logger.debug { 'Processing created event' }
        Tenant.find_by(schema_name: event.schema_name).switch do
          blob = ActiveStorage::Blob.create(key: event.key, filename: File.basename(event.key),
                                            content_type: 'text/csv', byte_size: event.size, checksum: event.etag)
          document = Document.create
          document.file.attach(blob)
          # download the blob, write it to a temp file and read the header
          header = Tempfile.create do |f|
            f << document.file.download
            f.rewind
            f.readline
          end.chomp
          document.update(header: header)
          document.identify_transfer_map
        end
      elsif event.type.eql? 'download'
        Rails.logger.debug { 'Processing download event' }
      else
        Rails.logger.debug { 'NOT Processing unknown event' }
      end
    end
  end

  # For an HTTP upload the uploaded file is already on the local filesystem referenced by the io param
  # so we just need to open the io object and read the first line
  def after_attach(io)
    update(header: File.open(io.tempfile, &:readline).chomp)
    identify_transfer_map
  end

  def identify_transfer_map
    file_columns = header.split(',').sort
    return unless (transfer_map_id = TransferMap.match(file_columns)&.id)

    update(transfer_map_id: transfer_map_id)
    enqueue
  end

  def enqueue
    Ros::StorageDocumentProcessJob.set(queue: target_service_queue).perform_later(job_payload.to_json)
  end

  # Service name where the job will be enqueued
  def target_service_queue; "#{transfer_map.service}_default" end

  def job_payload; attributes.slice('id') end

  def column_map
    return [] unless transfer_map

    transfer_map.column_maps.pluck(:user_name, :name).each_with_object({}) do |(key, value), hash|
      hash[key.to_sym] = value
    end
  end
end
