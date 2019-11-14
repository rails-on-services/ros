# frozen_string_literal: true

# arr = [
#  Ros::Urn.from_urn('urn:perx:iam::222222222:credential'),
#  Ros::Urn.from_urn('urn:perx:iam::*:credential',
#  Ros::Urn.from_urn('urn:perx:campaign::*',
#  Ros::Urn.from_urn('urn:perx:campaign::222222222:entity'
# ]

# arr.uniq

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

    def self.merge(urns)
      output = []
      loop do
        urns.each do |a|
          urns.each do |b|
            merged = Ros::Urn.compare(a, b)
            unless merged.nil?
              output.reject! { |i| i == a }
              a = merged
            end
            output << a
            output.uniq!
            output.reject!(&:nil?)
          end
        end
        break if urns.sort == output.sort

        urns = output
        output = []
      end
      output
    end

    # rubocop:disable Metrics/PerceivedComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/CyclomaticComplexity
    def self.compare(left, right)
      urn_breakdown = [
        { txt: 1 },
        { partition_name: 2 },
        { service_name: 3 },
        { region: 4 },
        { account_id: 5 },
        { resource: 6 }
      ]

      left = Ros::Urn.from_urn(Ros::Urn.flatten(left))
      right = Ros::Urn.from_urn(Ros::Urn.flatten(right))
      camparing_results = []
      consumer, wildcard_position = nil
      return nil if left.to_s == right.to_s

      urn_breakdown.each do |i|
        key = i.keys.first
        position = i.values.first
        left_value = left.send(key)
        right_value = right.send(key)

        if consumer.nil?
          if left_value != right_value && [left_value, right_value].include?('*')
            wildcard_position = position
            consumer = if left_value == '*'
                         left
                       elsif right_value == '*'
                         left
                       end
          end
        end
        camparing_results << (left_value == right_value || [left_value, right_value].include?('*'))
      end
      return unless camparing_results.all?

      if consumer.nil?
        nil
      else
        consumer.to_s
      end
    end
    # rubocop:enable Metrics/PerceivedComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/CyclomaticComplexity

    # TODO: Rename this, as this is not really flattening a urn but rather
    # filling the missing parts
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

    # TODO: Support incomplete URN String. Assume that if not present, then
    # add * if it ends in * (we can maybe call flatten)
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

    # NOTE: Orders first by more broad to more specific and then alphabetically
    def <=>(other)
      # NOTE: If string representation is a superset of the the other string
      # representation, then means that self comes first
      return - 1 if overlaps?(other)

      to_s <=> other.to_s
    end

    def overlaps?(other)
      str_rep = to_s
      other_str = other.to_s
      regex = Regexp.new(str_rep.gsub('*', '.*'))
      !regex.match(other_str).nil?
    end

    def hash
      1
    end

    def eql?(other)
      overlaps?(other) || other.overlaps?(self)
    end
  end
end
