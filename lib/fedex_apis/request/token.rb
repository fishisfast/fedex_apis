require_relative 'base'

module FedexApis
  module Request
    class Token < Base

      def run
        connection.post(
          path: '/oauth/token',
          headers: {
            'Content-Type' => 'application/x-www-form-urlencoded'
          },
          body: URI.encode_www_form({
            grant_type: 'client_credentials',
            client_id: options[:client_id],
            client_secret: options[:client_secret]
          })
        )
      end

    end
  end
end
