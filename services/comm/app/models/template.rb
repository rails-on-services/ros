# frozen_string_literal: true

class Template < Comm::ApplicationRecord
  attr_accessor :properties
  # belongs_to :campaign

  after_initialize :initialize_properties

  def initialize_properties
    self.properties = OpenStruct.new
  end

  # See: https://www.stuartellis.name/articles/erb/
  def render
    ERB.new(content.gsub('<%= ', '<%= properties.')).result(get_binding)
  end
end
