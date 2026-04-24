# frozen_string_literal: true

require_relative 'base'

module FedexApis
  module Request
    class DocumentUpload < Base
      SANDBOX_DOCUMENT_HOST = 'https://documentapitest.prod.fedex.com'
      PRODUCTION_DOCUMENT_HOST = 'https://documentapi.prod.fedex.com'

      SANDBOX_PATH = '/sandbox/documents/v1/lhsimages/upload'
      PRODUCTION_PATH = '/documents/v1/lhsimages/upload'

      def upload(access_token)
        boundary = "----FedexApis#{SecureRandom.hex(16)}"
        body = build_multipart_body(boundary)

        document_connection.post(
          path: upload_path,
          headers: {
            'Authorization' => "Bearer #{access_token}",
            'Content-Type' => "multipart/form-data; boundary=#{boundary}",
            'X-locale' => 'en_US'
          },
          body: body,
          timeout: 120
        )
      end

      private

      def sandbox?
        options[:host].to_s.include?('sandbox')
      end

      def document_host
        sandbox? ? SANDBOX_DOCUMENT_HOST : PRODUCTION_DOCUMENT_HOST
      end

      def upload_path
        sandbox? ? SANDBOX_PATH : PRODUCTION_PATH
      end

      def document_connection
        @document_connection ||= Excon.new(
          document_host,
          middlewares: Excon.defaults[:middlewares] + [Excon::Middleware::Decompress]
        )
      end

      def build_multipart_body(boundary)
        file_path = params[:file_path]
        file_name = File.basename(file_path)
        file_content = File.read(file_path, mode: 'rb')
        content_type = params[:content_type] || 'image/png'
        document_json = params[:document].to_json

        body = +''
        body << "--#{boundary}\r\n"
        body << "Content-Disposition: form-data; name=\"document\"\r\n"
        body << "Content-Type: application/json\r\n"
        body << "\r\n"
        body << document_json
        body << "\r\n"
        body << "--#{boundary}\r\n"
        body << "Content-Disposition: form-data; name=\"attachment\"; filename=\"#{file_name}\"\r\n"
        body << "Content-Type: #{content_type}\r\n"
        body << "\r\n"
        body << file_content
        body << "\r\n"
        body << "--#{boundary}--\r\n"
        body
      end
    end
  end
end
