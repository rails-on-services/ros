# frozen_string_literal: true

RSpec.shared_examples 'application record concern' do
  let(:partition_name) { Settings.partition_name }
  let(:service_name) { Settings.service.name }
  let(:region) { Settings.region }
  let(:account_id) { described_class.account_id }
  let(:underscore_name) { described_class.name.underscore }
  let(:urn) { "urn:#{partition_name}:#{service_name}:#{region}:#{account_id}:#{underscore_name}" }

  let(:factory_name) { described_class.name.underscore.to_sym }

  it 'has a factory' do
    expect { create(factory_name) }.not_to raise_error(KeyError)
  end

  # TODO: find the right place
  # context 'after created' do
  #   it 'enqueued job' do
  #     expect { subject }.to have_enqueued_job(Ros::PlatformConsumerEventJob)
  #   end
  # end

  context 'class methods' do
    it 'respond to name and its is not nil' do
      expect(described_class.respond_to?(:name)).to be_truthy
      expect(described_class.name).not_to be_nil
    end

    it 'respond to urn_base and its is not nil' do
      expect(described_class.respond_to?(:urn_base)).to be_truthy
      expect(described_class.urn_base).not_to be_nil
    end

    it 'respond to urn_id and its is not nil' do
      expect(described_class.respond_to?(:urn_id)).to be_truthy
      expect(described_class.urn_id).not_to be_nil
    end

    it 'related to current tennant' do
      expect(described_class.current_tenant).to eq(tenant)
    end

    it 'respond to to_urn and its valid' do
      expect(described_class.respond_to?(:to_urn)).to be_truthy
      expect(described_class.to_urn).to eq(urn)
    end
  end

  context 'instance methods' do
    it 'converts to urn' do
      expect(subject.respond_to?(:to_urn)).to be_truthy
      expect(subject.to_urn).to eq("#{urn}/#{subject.send(described_class.urn_id)}")
    end

    it 'related to valid tenant' do
      expect(subject.respond_to?(:current_tenant)).to be_truthy
      expect(subject.current_tenant).to eq(tenant)
    end
  end
end
