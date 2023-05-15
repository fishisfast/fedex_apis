require 'excon'
require 'json'

require_relative 'request/token'
require_relative 'resource/token'

require_relative 'request/rate'
require_relative 'resource/rate'

module FedexApis
  class Client

    OPTIONS = %i[host client_id client_secret account_number].freeze

    attr_accessor :options

    def initialize(options = {})
      @options = options
      load_env_options
    end

    def get_token
      response = Request::Token.new(@options).run
      Resource::Token.new(JSON.parse(response.body))
    end

    def rate(params)
      access_token = get_token.access_token
      response = Request::Rate.new(@options, params: params).run(access_token)
      Resource::Rate.new(JSON.parse(response.body))
    end

    private

    def load_env_options
      OPTIONS.each do |option|
        options[option] ||= ENV["FEDEX_APIS_#{option.upcase}"]
        raise ArgumentError, "Missing option: #{option}" if options[option].blank?
      end
    end

  end
end
