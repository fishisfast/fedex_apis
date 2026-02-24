# frozen_string_literal: true

require_relative 'base'

module FedexApis
  module Request
    class Shipment < Base
      def initialize(conn_options = {}, params: {})
        super
        prepare_params
      end

      def create(access_token)
        connection.post(
          path: 'ship/v1/shipments',
          headers: {
            'Authorization' => "Bearer #{access_token}"
          },
          body: params.to_json,
          timeout: 120
        )
      end

      def validate(access_token)
        connection.post(
          path: 'ship/v1/shipments/packages/validate',
          headers: {
            'Authorization' => "Bearer #{access_token}"
          },
          body: params.to_json,
          timeout: 120
        )
      end

      def cancel(access_token, tracking_number)
        cancel_params = {
          accountNumber: {
            value: options[:account_number]
          },
          trackingNumber: tracking_number
        }

        connection.put(
          path: 'ship/v1/shipments/cancel',
          headers: {
            'Authorization' => "Bearer #{access_token}"
          },
          body: cancel_params.to_json,
          timeout: 120
        )
      end

      private

      def prepare_params
        raise ArgumentError, ':account_number is required' if options[:account_number].blank?

        # Add account number to params if not already present
        params[:accountNumber] ||= { value: options[:account_number] }
      end
    end
  end
end
