# frozen_string_literal: true

module FedexApis
  module Resource
    class Tracking
      attr_reader :status, :output

      SUCCESS_STATUSES = [200].freeze

      def initialize(status, body)
        @status = status
        parsed_body = JSON.parse(body)
        @output = parsed_body['output'] || parsed_body
      end

      def success?
        SUCCESS_STATUSES.include?(status)
      end

      def [](key)
        output[key]
      end

      def method_missing(method_name, *args)
        return output[method_name.to_s] if output.key?(method_name.to_s)

        super
      end

      def respond_to_missing?(method_name, include_private = false)
        output.key?(method_name.to_s) || super
      end

      def to_h
        output
      end
    end
  end
end
