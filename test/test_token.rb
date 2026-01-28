# frozen_string_literal: true

require 'test_helper'

class TestFedexApis < Minitest::Test
  def test_token
    VCR.use_cassette('token') do
      token = client.token

      refute_nil token.access_token
    end
  end
end
