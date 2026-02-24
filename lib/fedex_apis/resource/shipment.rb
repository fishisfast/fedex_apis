# frozen_string_literal: true

require 'base64'
require 'open-uri'

module FedexApis
  module Resource
    class Shipment
      attr_reader :status, :data

      SUCCESS_STATUSES = [200, 201].freeze

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

      # Convenience methods for common shipment data access

      def master_tracking_number
        data.dig('output', 'transactionShipments', 0, 'masterTrackingNumber')
      end

      def tracking_numbers
        shipments = data.dig('output', 'transactionShipments') || []
        shipments.flat_map do |shipment|
          packages = shipment['pieceResponses'] || []
          packages.map { |pkg| pkg['trackingNumber'] }
        end.compact
      end

      def tracking_number
        tracking_numbers.first
      end

      def labels
        shipments = data.dig('output', 'transactionShipments') || []
        shipments.flat_map do |shipment|
          packages = shipment['pieceResponses'] || []
          packages.map do |pkg|
            next unless pkg['packageDocuments']

            pkg['packageDocuments'].find { |doc| doc['contentType'] == 'LABEL' }
          end
        end.compact
      end

      def label
        labels.first
      end

      # Helper method to get label URL (handles both url and encodedLabel)
      def label_url
        label&.dig('url')
      end

      # Helper method to get all label URLs
      def label_urls
        labels.map { |l| l['url'] }.compact
      end

      # Helper method to check if label is base64 encoded
      def label_encoded?
        label&.key?('encodedLabel')
      end

      # Helper method to get base64 encoded label data
      def label_data
        label&.dig('encodedLabel')
      end

      # Helper method to get all encoded label data
      def label_data_all
        labels.map { |l| l['encodedLabel'] }.compact
      end

      # Consistent interface methods - always return binary label data

      # Get label content as binary string (handles both URL and base64 formats)
      # Returns the first/only label content
      #
      # Note: For URL-based labels, the URL may expire quickly. Download immediately.
      # In test environments, URLs may return 404 or require authentication.
      #
      # @param download_url [Boolean] Whether to attempt URL download (default: true)
      # @return [String, nil] Binary string of label content (e.g., PDF bytes)
      def label_content(download_url: true)
        return nil unless label

        if label['encodedLabel']
          # Base64 encoded - decode it
          Base64.decode64(label['encodedLabel'])
        elsif label['url'] && download_url
          # URL - download it
          download_from_url(label['url'])
        else
          nil
        end
      end

      # Get all label contents as array of binary strings (for MPS)
      # @param download_url [Boolean] Whether to attempt URL download (default: true)
      # @return [Array<String>] Array of binary strings
      def label_contents(download_url: true)
        labels.map do |lbl|
          if lbl['encodedLabel']
            Base64.decode64(lbl['encodedLabel'])
          elsif lbl['url'] && download_url
            download_from_url(lbl['url'])
          else
            nil
          end
        end.compact
      end

      # Save label to file (handles both URL and base64 formats)
      # @param path [String] File path to save the label
      # @param download_url [Boolean] Whether to attempt URL download (default: true)
      # @return [Boolean] true if saved successfully
      def save_label(path, download_url: true)
        content = label_content(download_url: download_url)
        return false unless content

        File.write(path, content, mode: 'wb')
        true
      end

      # Save all labels to directory (for MPS)
      # Files will be named: label_1.pdf, label_2.pdf, etc.
      # @param directory [String] Directory path to save labels
      # @param prefix [String] Filename prefix (default: 'label')
      # @param download_url [Boolean] Whether to attempt URL download (default: true)
      # @return [Array<String>] Array of saved file paths
      def save_labels(directory, prefix: 'label', download_url: true)
        return [] if labels.empty?

        # Create directory if it doesn't exist
        require 'fileutils'
        FileUtils.mkdir_p(directory)

        saved_files = []
        label_contents(download_url: download_url).each_with_index do |content, index|
          # Determine extension from docType
          ext = labels[index]['docType']&.downcase || 'pdf'
          filename = "#{prefix}_#{index + 1}.#{ext}"
          filepath = File.join(directory, filename)

          File.write(filepath, content, mode: 'wb')
          saved_files << filepath
        end

        saved_files
      end

      private

      # Download label content from URL with error handling
      # @param url [String] URL to download from
      # @return [String, nil] Binary content or nil on failure
      def download_from_url(url)
        URI.open(url, &:read)
      rescue StandardError => e
        # URL may be expired, require auth, or be test data
        # Return nil to allow graceful handling
        warn "Warning: Failed to download label from URL (#{e.class}: #{e.message}). URL may be expired or inaccessible."
        nil
      end

      public

      def documents
        shipments = data.dig('output', 'transactionShipments') || []
        all_docs = []

        shipments.each do |shipment|
          # Shipment-level documents
          if shipment['shipmentDocuments']
            all_docs.concat(shipment['shipmentDocuments'])
          end

          # Package-level documents
          packages = shipment['pieceResponses'] || []
          packages.each do |pkg|
            if pkg['packageDocuments']
              all_docs.concat(pkg['packageDocuments'])
            end
          end
        end

        all_docs
      end

      def document(doc_type = nil)
        return documents.first if doc_type.nil?

        documents.find { |doc| doc['docType'] == doc_type }
      end

      # Alert/error methods

      def alerts
        shipment_alerts = data.dig('output', 'alerts') || []
        transaction_alerts = data.dig('output', 'transactionShipments')&.flat_map { |s| s['alerts'] || [] } || []
        (shipment_alerts + transaction_alerts).uniq
      end

      def errors
        data['errors'] || []
      end

      def has_alerts?
        !alerts.empty?
      end

      def has_errors?
        !errors.empty?
      end
    end
  end
end
