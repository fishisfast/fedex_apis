# frozen_string_literal: true

require "test_helper"

class TestRate < Minitest::Test

  def test_rate
    VCR.use_cassette('rate') do
      rate = client.rate(rate_data)
      puts JSON.pretty_generate(rate_data).gsub(":", " =>")


      quotes = rate.output['rateReplyDetails']

      assert rate.status == 200
      assert rate.success?

      refute_nil quotes
      refute_empty quotes
      assert quotes.is_a?(Array)
      assert quotes.size > 0
    end
  end

  private

  def rate_data
    load_json_fixture('requests/rate')
  end
end
