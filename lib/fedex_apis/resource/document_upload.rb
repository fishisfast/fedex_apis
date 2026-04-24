# frozen_string_literal: true

module FedexApis
  module Resource
    class DocumentUpload
      attr_reader :status, :data

      SUCCESS_STATUSES = [200, 201, 202].freeze

      def initialize(status, body)
        @status = status
        @data = parse_body(body)
      end

      def success?
        SUCCESS_STATUSES.include?(status)
      end

      def [](key)
        data[key]
      end

      def method_missing(method_name, *args)
        return data[method_name.to_s] if data.is_a?(Hash) && data.key?(method_name.to_s)

        super
      end

      def respond_to_missing?(method_name, include_private = false)
        (data.is_a?(Hash) && data.key?(method_name.to_s)) || super
      end

      def to_h
        data
      end

      def errors
        return [] unless data.is_a?(Hash)

        data['errors'] || []
      end

      def has_errors?
        !errors.empty?
      end

      # Document reference ID from the response
      def reference_id
        data.dig('output', 'referenceId') || data.dig('referenceId')
      end

      # Document ID from the response
      def document_id
        data.dig('output', 'documentId') || data.dig('documentId')
      end

      private

      def parse_body(body)
        return {} if body.nil? || body.empty?

        JSON.parse(body)
      rescue JSON::ParserError
        { 'raw_body' => body }
      end
    end
  end
end
