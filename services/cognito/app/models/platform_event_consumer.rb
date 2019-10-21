# frozen_string_literal: true

class PlatformEventConsumer
  include Ros::PlatformEventConsumerConcern
  # attr_accessor :event

  # def initialize(event)
  #   @event = event
  # end

  # # TODO: Maybe this should be a class in core and can have common methods that are executed
  # # on all services
  # def storage_document
  #   Rails.logger.debug event
  #   Ros::Infra.resources.storage.app.cp(event.data['source_path'])
  #   local_path = "#{Rails.root}/tmp/fs/#{File.basename(event.data['source_path'])}"
  #   klass = event.data['target'].classify.constantize
  #   klass.load_document(local_path, event.data['column_map'], true)
  # end
end
