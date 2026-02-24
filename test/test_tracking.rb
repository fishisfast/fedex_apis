# frozen_string_literal: true

require 'test_helper'

class TestTracking < Minitest::Test
  def test_tracking
    VCR.use_cassette('tracking') do
      tracking = client.track(tracking_data)

      assert_equal 200, tracking.status
      assert_predicate tracking, :success?

      assert_complete_track_results(tracking)
      assert_track_results(tracking)
      assert_scan_events(tracking)
    end
  end

  private

  def tracking_data
    load_json_fixture('requests/tracking')
  end

  def assert_complete_track_results(tracking)
    complete_track_results = tracking.output['completeTrackResults']

    refute_empty complete_track_results
  end

  def assert_track_results(tracking)
    track_results = get_track_results(tracking)

    refute_nil track_results
    refute_empty track_results
    assert_kind_of Array, track_results
    assert_predicate track_results.size, :positive?
  end

  def assert_scan_events(tracking)
    scan_events = get_scan_events(tracking)

    refute_nil scan_events
    refute_empty scan_events
    assert_kind_of Array, scan_events
    assert_predicate scan_events.size, :positive?
  end

  def get_track_results(tracking)
    tracking.output['completeTrackResults'].first['trackResults']
  end

  def get_scan_events(tracking)
    get_track_results(tracking).first['scanEvents']
  end
end
