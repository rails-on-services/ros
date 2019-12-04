# frozen_string_literal: true

RSpec.shared_examples 'operation job' do
  let(:with_arguments) { {} }
  let(:described_operation) { described_class.name.gsub('Job', '').constantize }

  before do
    allow(described_operation).to receive(:call)
    described_class.perform_now(with_arguments)
  end

  it 'triggers the matching operation' do
    expect(described_operation).to have_received(:call).once.with([with_arguments])
  end
end
