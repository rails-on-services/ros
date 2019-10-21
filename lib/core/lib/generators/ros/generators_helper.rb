# frozen_string_literal: true

module Ros
  module GeneratorsHelper
    def name_cp
      name.classify.pluralize
    end

    def parent_module
      engine? ? "#{Settings.service.name.classify}::" : ''
    end

    def engine?
      Dir["#{Dir.pwd}/lib/**/engine.rb"].any?
    end
  end
end
