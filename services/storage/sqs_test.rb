require 'aws-sdk-sqs'

class Q
  attr_accessor :client, :queue_name, :queue

  def initialize(queue_name)
    self.client = Aws::SQS::Client.new(access_key_id: 'hello', secret_access_key: 'test',
                                       # region: 'ap-southeast-1',  endpoint: 'http://localhost:4576')
                                       region: 'ap-southeast-1',  endpoint: 'http://localstack:4576')
    self.queue_name = queue_name
    attrs = queue_name.end_with?('.fifo') ? { 'FifoQueue' => 'true', 'ContentBasedDeduplication' => 'true' } : {}
    self.queue = client.create_queue({ queue_name: queue_name,
                                       attributes: attrs })
                                       # attributes: { 'All' => 'String', 'FifoQueue' => 'true' }})
  end

  def queue_url
    "http://localstack:4576/queue/#{queue_name}"
  end

  # Credential.last.to_json}
  def send_message(id, did, body)
    # client.send_message({ queue_url: queue_url, message_body: body, message_group_id: id, message_deduplication_id: did })
    # client.send_message({ queue_url: queue_url, message_body: body, message_group_id: 'test' })
    client.send_message({ queue_url: queue_url, message_body: body })
  end

  # Credential.new JSON.parse(resp.messages.first.body).except('urn')
  def receive_message
    client.receive_message({ queue_url: queue_url })
  end

  def delete_message(handle)
    client.delete_message({ queue_url: queue_url, receipt_handle: handle })
  end
end
