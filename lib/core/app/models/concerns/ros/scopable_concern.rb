# frozen_string_literal: true

module Ros
  module ScopableConcern
    extend ActiveSupport::Concern

    included do
      scope :everything, ->(_user_context) { all }
      scope :owned, ->(_user_context) { all }
    end
  end
end
