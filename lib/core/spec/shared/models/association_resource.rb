# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
RSpec.shared_examples 'it belongs_to_resource' do |resource|
  it { should respond_to resource }

  describe 'association config' do
    let(:resource_config) { described_class.find_resource(resource) }
    let(:polymorphic) { resource_config.polymorphic }

    it 'should be instance of BelongsToResource class' do
      expect(resource_config).to be_instance_of(AssociationResource::BelongsToResource)
    end

    context 'Default' do
      before do
        skip if polymorphic
      end

      it 'class should respond_to given :foreign_key' do
        expect(described_class.column_names).to include(resource_config.foreign_key)
      end

      context 'Resource class' do
        subject { described_class.find_resource(resource).class_name.classify.safe_constantize }

        it 'should be defined' do
          expect(subject).not_to be_nil
        end

        it { should respond_to :where }
        it { should respond_to :find }
      end
    end

    context 'Polymorphic' do
      before do
        skip unless polymorphic
      end

      subject { described_class.column_names }

      it { should include("#{resource}_id") }
      it { should include("#{resource}_type") }
    end
  end
end
# rubocop:enable Metrics/BlockLength

RSpec.shared_examples 'it has_many_resources' do |resource|
  it { should respond_to resource }

  describe 'association config' do
    let(:resource_config) { described_class.find_resource(resource) }

    it 'should be instance of HasManyResources class' do
      expect(resource_config).to be_instance_of(AssociationResource::HasManyResources)
    end

    context 'Resource class' do
      subject { described_class.find_resource(resource).class_name.classify.safe_constantize }

      it 'should be defined' do
        expect(subject).not_to be_nil
      end

      it { should respond_to :where }
      it { should respond_to :find }
    end
  end
end
