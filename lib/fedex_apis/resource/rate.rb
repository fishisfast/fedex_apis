# frozen_string_literal: true

module FedexApis
  module Resource
    class Rate
      attr_reader :status, :data

      SUCCESS_STATUSES = [200].freeze

      def initialize(status, body)
        @status = status
        @data = JSON.parse(body)
      end

      def success?
        SUCCESS_STATUSES.include?(status)
      end

      def [](key)
        data[key]
      end

      def method_missing(method_name, *args)
        return data[method_name.to_s] if data.key?(method_name.to_s)

        super
      end

      def respond_to_missing?(method_name, include_private = false)
        data.key?(method_name.to_s) || super
      end

      def to_h
        data
      end
    end
  end
end
