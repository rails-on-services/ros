module Ros
  module GeneratorsHelper
    def name_cp
      name.classify.pluralize
    end

    def parent_module
      engine? ? "#{Dir.pwd.split('/').last.remove('ros-').classify}::" : ''
    end

    private

    def engine?
      Dir["#{Dir.pwd}/lib/**/engine.rb"].any?
    end
  end
end
