# frozen_string_literal: true

require "test_helper"

class TestFedexApis < Minitest::Test

  def test_get_token
    VCR.use_cassette('token') do
      token = client.get_token
      refute_nil token.access_token
    end
  end

end
