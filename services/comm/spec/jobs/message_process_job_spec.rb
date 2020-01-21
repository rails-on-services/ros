# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MessageProcessJob, type: :job do
  include_examples 'operation job'
end
