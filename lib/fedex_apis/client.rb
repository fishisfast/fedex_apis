# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'excon'
require 'json'

require_relative 'request/token'
require_relative 'resource/token'

require_relative 'request/rate'
require_relative 'resource/rate'

require_relative 'request/tracking'
require_relative 'resource/tracking'

require_relative 'request/shipment'
require_relative 'resource/shipment'

require_relative 'request/document_upload'
require_relative 'resource/document_upload'

module FedexApis
  class Client
    OPTIONS = %i[host client_id client_secret account_number].freeze

    attr_accessor :options

    def initialize(options = {})
      @options = options
      load_env_options
    end

    def token
      response = Request::Token.new(@options).run
      Resource::Token.new(JSON.parse(response.body))
    end

    def rate(params)
      access_token = token.access_token
      response = Request::Rate.new(@options, params: params).run(access_token)
      Resource::Rate.new(response.status, response.body)
    end

    def track(params)
      access_token = token.access_token
      response = Request::Tracking.new(@options, params: params).run(access_token)
      Resource::Tracking.new(response.status, response.body)
    end

    def create_shipment(params)
      access_token = token.access_token
      response = Request::Shipment.new(@options, params: params).create(access_token)
      Resource::Shipment.new(response.status, response.body)
    end

    def validate_shipment(params)
      access_token = token.access_token
      response = Request::Shipment.new(@options, params: params).validate(access_token)
      Resource::Shipment.new(response.status, response.body)
    end

    def cancel_shipment(tracking_number)
      access_token = token.access_token
      response = Request::Shipment.new(@options).cancel(access_token, tracking_number)
      Resource::Shipment.new(response.status, response.body)
    end

    # Upload a letterhead or signature image for ETD (Electronic Trade Documents).
    #
    # @param file_path [String] Path to the image file to upload
    # @param image_type [String] "SIGNATURE" or "LETTERHEAD"
    # @param reference_id [String] A reference identifier for the image
    # @param image_index [String] "IMAGE_1" for letterhead, "IMAGE_2" for signature (default based on image_type)
    # @param content_type [String] MIME type of the file (default: "image/png")
    # @return [Resource::DocumentUpload]
    def upload_document_image(file_path, image_type:, reference_id:, image_index: nil, content_type: 'image/png')
      raise ArgumentError, "File not found: #{file_path}" unless File.exist?(file_path)
      raise ArgumentError, "File is not readable: #{file_path}" unless File.readable?(file_path)

      image_index ||= image_type == 'LETTERHEAD' ? 'IMAGE_1' : 'IMAGE_2'

      params = {
        file_path: file_path,
        content_type: content_type,
        document: {
          document: {
            referenceId: reference_id,
            name: File.basename(file_path),
            contentType: content_type,
            meta: {
              imageType: image_type,
              imageIndex: image_index
            }
          },
          rules: {
            workflowName: 'LetterheadSignature'
          }
        }
      }

      access_token = token.access_token
      response = Request::DocumentUpload.new(@options, params: params).upload(access_token)
      Resource::DocumentUpload.new(response.status, response.body)
    end

    # Convenience method to upload a signature image
    def upload_signature_image(file_path, reference_id:, content_type: 'image/png')
      upload_document_image(file_path, image_type: 'SIGNATURE', reference_id: reference_id, content_type: content_type)
    end

    # Convenience method to upload a letterhead image
    def upload_letterhead_image(file_path, reference_id:, content_type: 'image/png')
      upload_document_image(file_path, image_type: 'LETTERHEAD', reference_id: reference_id, content_type: content_type)
    end

    private

    def load_env_options
      OPTIONS.each do |option|
        options[option] ||= ENV.fetch("FEDEX_APIS_#{option.upcase}", nil)
        raise ArgumentError, "Missing option: #{option}" if options[option].blank?
      end
    end
  end
end
