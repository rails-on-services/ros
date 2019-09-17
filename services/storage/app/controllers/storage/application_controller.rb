# frozen_string_literal: true

module Storage
  class ApplicationController < ::ApplicationController

    def current_storage
      @storage ||= UploadStorage.find_or_create!
    end
  end
end
