require_relative 'base'

module FedexApis
  module Request
    class Tracking < Base

      def initialize(conn_options = {}, params: {})
        super
      end

      def run(access_token)
        connection.post(
          path: 'track/v1/trackingnumbers',
          headers: {
            'Authorization' => "Bearer #{access_token}",
          },
          body: params.to_json
        )
      end

    end
  end
end
