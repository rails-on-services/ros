# frozen_string_literal: true

module Ros
  class StorageDocumentProcess
    # When the remote service's worker picks the job from its queue it needs the following information:
    # The platform_event_data which consists of:
    #   The transfer_map target, e.g. user, which is the remote service's class that will be invoked
    #   The column_mapping which is a hash of CSV column names to table column names
    #   The path to the file on the bucket
    # It then determines the file type and does whatever it is supposed to do for a file of this type
    def call(json)
      setup(JSON.parse(json)['id'])
      copy_from_source
      return unless target_class.load_document(local_path, @document.column_map, true)

      @document.update(platform_event_state: :processed)
    end

    private

    def setup(id)
      @document = Ros::Storage::Document.find(id).first
    end

    def copy_from_source
      Ros::Infra.resources.storage.app.cp(source_path)
    end

    def target_class
      @document.target.classify.constantize
    end

    def local_path
      "#{Rails.root}/tmp/fs/#{File.basename(source_path)}"
    end

    def source_path
      @document.blob['key']
    end
  end
end
