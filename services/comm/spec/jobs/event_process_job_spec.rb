# frozen_string_literal: true

require 'rails_helper'

RSpec.describe EventProcessJob, type: :job do
  include_examples 'operation job' do
    let(:with_arguments) { { id: 1 } }
  end
end
