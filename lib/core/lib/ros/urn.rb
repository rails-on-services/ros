# frozen_string_literal: true

module Ros
  class Urn
    attr_accessor :txt, :partition_name, :service_name, :region, :account_id, :resource

    def initialize(txt, partition_name, service_name, region, account_id, resource)
      @txt = txt
      @partition_name = partition_name
      @service_name = service_name
      @region = region
      @account_id = account_id
      @resource = resource
    end

    def self.merge_urns(urns)
      output = []
      while true do
        for a in urns do
          for b in urns do
            merged = Ros::Urn.campare_urns(a, b)
            unless merged.nil?
              output.reject!{|i| i == a}
              a = merged
            end
            output << a
            output.uniq!
            output.reject!{|i| i.nil? }
          end
        end
        break if urns.sort == output.sort

        urns = output
        output = []
      end
      output
    end

    def self.campare_urns(left, right)
      urn_breakdown = [
        { txt: 1 },
        { partition_name: 2 },
        { service_name: 3 },
        { region: 4 },
        { account_id: 5 },
        { resource: 6 }
      ]

      left, right = Ros::Urn.from_urn(Ros::Urn.flatten(left)), Ros::Urn.from_urn(Ros::Urn.flatten(right))
      camparing_results = []
      consumer, wildcard_position = nil
      return nil if left.to_s == right.to_s
      urn_breakdown.each do |i|
        key = i.keys.first
        position = i.values.first
        left_value, right_value = left.send(key), right.send(key)

        if consumer.nil?
          if left_value != right_value && [left_value, right_value].include?('*')
            (consumer, wildcard_position = left, position) if left_value == '*'
            (consumer, wildcard_position = right, position) if right_value == '*'
          end
        end
        camparing_results << (left_value == right_value || [left_value, right_value].include?('*'))
      end
      if camparing_results.all?
        if consumer.nil?
          nil
        else
          consumer.to_s
        end
      else
        nil
      end
    end

    def self.flatten(urn)
      splitted = urn.split(':')
      if splitted.last.eql?('*') || splitted.size == 6
        6.times do |i|
          next if splitted[i]

          splitted[i] = '*'
        end
      elsif splitted.count('*') > 1
        raise ArgumentError
      else
        raise NotImplementedError
      end

      splitted.join(':')
    end

    def self.from_urn(urn_string)
      urn_array = urn_string.split(':')
      new(*urn_array)
    end

    def self.from_jwt(token)
      jwt = Jwt.new(token)
      return unless (urn_string = jwt.decode['sub'])

      from_urn(urn_string)
    # NOTE: Intentionally swallow decode error and return nil
    # rubocop:disable Lint/HandleExceptions
    rescue JWT::DecodeError
    end
    # rubocop:enable Lint/HandleExceptions

    def resource_type; resource.split('/').first end

    def resource_id; resource.split('/').last end

    def model_name; resource_type.classify end

    def model; model_name.constantize end

    # rubocop:disable Rails/DynamicFindBy
    def instance; model.find_by_urn(resource_id) end
    # rubocop:enable Rails/DynamicFindBy

    def to_s; to_a.join(':') end

    def to_a
      [@txt, @partition_name, @service_name, @region, @account_id, @resource]
    end
  end
end
