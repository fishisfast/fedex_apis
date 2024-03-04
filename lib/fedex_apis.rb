# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/string'

require_relative "fedex_apis/version"
require_relative "fedex_apis/client"

module FedexApis
  class Error < StandardError; end

  def self.root
    File.dirname __dir__
  end
end
