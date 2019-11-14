# frozen_string_literal: true

# NOTE: This gives URN ability to an active record:
# 1. Build URN for the active record
# 2. Find a record from a URN
module Ros
  module UrnConcern
    extend ActiveSupport::Concern

    class_methods do
      # urn:partition:service:region:account_id:resource_type
      def to_urn; "#{urn_base}:#{account_id}:#{name.underscore}" end

      # Universal Resource Name (URNs) and Service Namespaces
      # urn:partition:service:region
      def urn_base; "urn:#{Settings.partition_name}:#{Settings.service.name}:#{Settings.region}" end

      def find_by_urn(value); find_by(urn_id => value) end

      # NOTE: Override in model to provide a custom id
      def urn_id; :id end

    #   def urn_match?(urn_to_compare)
    #     params = %i[txt partition_name service_name region account_id resource]
    #     record_urn = Ros::Urn.from_urn(to_urn)
    #     urn_to_compare = Ros::Urn.from_urn(Ros::Urn.flatten(urn_to_compare))
    #     matches = []
    #     params.each do |param|
    #       matches << (record_urn.send(param) == urn_to_compare.send(param) || urn_to_compare.send(param) == '*')
    #     end
    #     matches.all?
    #   end
    end

    included do
      # urn:partition:service:region:account_id:resource_type/id
      def to_urn; "#{self.class.to_urn}/#{send(self.class.urn_id)}" end

      # def urn_match?(urn_to_compare); self.class.urn_match?(urn_to_compare); end

      def as_json(*)
        super.merge('urn' => to_urn)
      end
    end
  end
end
