# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'fedex_apis'

require 'minitest'
require 'minitest/autorun'
require 'minitest/reporters'
require 'minitest/rg'

require 'dotenv/load'
require 'vcr'
require 'debug'

# add color output
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]

VCR.configure do |config|
  config.cassette_library_dir = 'test/vcr_cassettes'
  config.hook_into :excon
  config.default_cassette_options = {
    decode_compressed_response: true
  }

  config.filter_sensitive_data('<FILTERED_CLIENT_ID>') { ENV.fetch('FEDEX_APIS_CLIENT_ID', nil) }
  config.filter_sensitive_data('<FILTERED_CLIENT_SECRET>') { ENV.fetch('FEDEX_APIS_CLIENT_SECRET', nil) }
  config.filter_sensitive_data('<FILTERED_ACCOUNT_NUMBER>') { ENV.fetch('FEDEX_APIS_ACCOUNT_NUMBER', nil) }
end

module Minitest
  class Test
    def client
      FedexApis::Client.new
    end

    def load_json_fixture(name)
      json_data = File.read(File.join(FedexApis.root, "test/fixtures/#{name}.json"))
      JSON.parse(json_data)
    end
  end
end
