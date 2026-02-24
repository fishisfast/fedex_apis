# frozen_string_literal: true

require 'test_helper'

class TestRate < Minitest::Test
  def test_rate
    VCR.use_cassette('rate') do
      rate = client.rate(rate_data)

      quotes = rate.output['rateReplyDetails']

      assert_equal 200, rate.status
      assert_predicate rate, :success?

      refute_nil quotes
      refute_empty quotes
      assert_kind_of Array, quotes
      assert_predicate quotes.size, :positive?
    end
  end

  private

  def rate_data
    load_json_fixture('requests/rate')
  end
end
