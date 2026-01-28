# frozen_string_literal: true

require_relative 'base'

module FedexApis
  module Request
    class Token < Base
      def run
        connection.post(
          path: '/oauth/token',
          headers: headers,
          body: form_body,
          timeout: 5
        )
      end

      private

      def headers
        { 'Content-Type' => 'application/x-www-form-urlencoded' }
      end

      def form_body
        URI.encode_www_form({
                              grant_type: 'client_credentials',
                              client_id: options[:client_id],
                              client_secret: options[:client_secret]
                            })
      end
    end
  end
end
