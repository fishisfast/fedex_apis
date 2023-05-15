module FedexApis
  module Request
    class Base

      attr_accessor :options, :params

      def initialize(options = {}, params: {})
        @options = options
        @params = params
      end

      def connection
        @connection ||= Excon.new(
          @options[:host],
          headers: {
            'Content-Type' => 'application/json',
            'X-Locale' => 'en_US',
          },
          middlewares: Excon.defaults[:middlewares] + [Excon::Middleware::Decompress]
        )
      end

    end
  end
end
