# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "fedex_apis"

require "minitest/autorun"

require "dotenv/load"
require "vcr"

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :excon

  config.filter_sensitive_data('<FILTERED_CLIENT_ID>') { ENV['FEDEX_APIS_CLIENT_ID'] }
  config.filter_sensitive_data('<FILTERED_CLIENT_SECRET>') { ENV['FEDEX_APIS_CLIENT_SECRET'] }
  config.filter_sensitive_data('<FILTERED_ACCOUNT_NUMBER>') { ENV['FEDEX_APIS_ACCOUNT_NUMBER'] }
end
