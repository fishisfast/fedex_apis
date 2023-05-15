require_relative 'base'

module FedexApis
  module Request
    class Rate < Base

      def initialize(conn_options = {}, params: {})
        super
        prepare_params
      end

      def run(access_token)
        connection.post(
          path: 'rate/v1/rates/quotes',
          headers: {
            'Authorization' => "Bearer #{access_token}",
          },
          body: params.to_json
        )
      end

      private
      def prepare_params
        raise ArgumentError, ':account_number is required' if options[:account_number].blank?

        params[:accountNumber] = { value: options[:account_number] }
      end

    end
  end
end
