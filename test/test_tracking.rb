# frozen_string_literal: true

require "test_helper"

class TestTracking < Minitest::Test

  def test_tracking
    VCR.use_cassette('tracking') do
      tracking = client.track(tracking_data)

      assert tracking.status == 200
      assert tracking.success?

      complete_track_results = tracking.output['completeTrackResults']
      refute_empty complete_track_results

      track_results = complete_track_results.first['trackResults']
      refute_nil track_results
      refute_empty track_results
      assert track_results.is_a?(Array)
      assert track_results.size > 0

      scan_events = track_results.first['scanEvents']
      refute_nil scan_events
      refute_empty scan_events
      assert scan_events.is_a?(Array)
      assert scan_events.size > 0
    end
  end

  private

  def tracking_data
    load_json_fixture('requests/tracking')
  end
end
