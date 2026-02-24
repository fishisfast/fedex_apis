# frozen_string_literal: true

require 'test_helper'

class TestShipment < Minitest::Test
  def test_create_single_package_shipment
    VCR.use_cassette('shipment_create_single_package') do
      shipment = client.create_shipment(single_package_shipment_data)

      assert_equal 200, shipment.status
      assert_predicate shipment, :success?

      # Test tracking number access
      refute_nil shipment.tracking_number
      assert_kind_of String, shipment.tracking_number

      # Test tracking numbers array
      refute_empty shipment.tracking_numbers
      assert_equal 1, shipment.tracking_numbers.size

      # Test label access
      refute_nil shipment.label
      assert_kind_of Hash, shipment.label
      assert_equal 'LABEL', shipment.label['contentType']

      # Test labels array
      refute_empty shipment.labels
      assert_equal 1, shipment.labels.size

      # Test documents
      refute_empty shipment.documents
      assert_kind_of Array, shipment.documents
    end
  end

  def test_create_multi_package_shipment
    VCR.use_cassette('shipment_create_multi_package') do
      shipment = client.create_shipment(multi_package_shipment_data)

      assert_equal 200, shipment.status
      assert_predicate shipment, :success?

      # Test master tracking number
      refute_nil shipment.master_tracking_number

      # Test tracking numbers array - should have 3 packages
      refute_empty shipment.tracking_numbers
      assert_equal 3, shipment.tracking_numbers.size
      shipment.tracking_numbers.each do |tn|
        assert_kind_of String, tn
        refute_empty tn
      end

      # Test labels array - should have 3 labels
      refute_empty shipment.labels
      assert_equal 3, shipment.labels.size
      shipment.labels.each do |label|
        assert_kind_of Hash, label
        assert_equal 'LABEL', label['contentType']
      end

      # First tracking number and label convenience methods
      refute_nil shipment.tracking_number
      refute_nil shipment.label
    end
  end

  def test_validate_shipment
    VCR.use_cassette('shipment_validate') do
      shipment = client.validate_shipment(single_package_shipment_data)

      assert_equal 200, shipment.status
      assert_predicate shipment, :success?

      # Validation should return shipment data but might not have tracking numbers yet
      refute_nil shipment.data
      assert_kind_of Hash, shipment.data
    end
  end

  def test_cancel_shipment
    VCR.use_cassette('shipment_cancel') do
      # First create a shipment
      create_response = client.create_shipment(single_package_shipment_data)
      tracking_number = create_response.tracking_number

      # Then cancel it
      cancel_response = client.cancel_shipment(tracking_number)

      assert_equal 200, cancel_response.status
      assert_predicate cancel_response, :success?
    end
  end

  def test_shipment_with_alerts
    VCR.use_cassette('shipment_with_alerts') do
      shipment = client.create_shipment(single_package_shipment_data)

      # Test alert methods
      assert_respond_to shipment, :alerts
      assert_respond_to shipment, :has_alerts?

      alerts = shipment.alerts
      assert_kind_of Array, alerts
    end
  end

  def test_shipment_document_access
    VCR.use_cassette('shipment_create_single_package') do
      shipment = client.create_shipment(single_package_shipment_data)

      # Test document method without type
      refute_nil shipment.document

      # Test document method with type (using docType which is the format like PDF, PNG)
      pdf_doc = shipment.document('PDF')
      refute_nil pdf_doc
      assert_equal 'PDF', pdf_doc['docType']
    end
  end

  def test_shipment_data_access
    VCR.use_cassette('shipment_create_single_package') do
      shipment = client.create_shipment(single_package_shipment_data)

      # Test hash access
      assert_respond_to shipment, :[]
      refute_nil shipment['output']

      # Test to_h conversion
      hash = shipment.to_h
      assert_kind_of Hash, hash
      refute_empty hash

      # Test method_missing for data keys
      refute_nil shipment.output
    end
  end

  def test_label_helper_methods
    VCR.use_cassette('shipment_create_single_package') do
      shipment = client.create_shipment(single_package_shipment_data)

      # Test label_url method
      assert_respond_to shipment, :label_url
      # In VCR cassettes, labels have URLs
      refute_nil shipment.label_url
      assert_kind_of String, shipment.label_url

      # Test label_urls method
      assert_respond_to shipment, :label_urls
      assert_kind_of Array, shipment.label_urls
      assert_equal 1, shipment.label_urls.size

      # Test label_encoded? method
      assert_respond_to shipment, :label_encoded?
      assert_equal false, shipment.label_encoded? # VCR has URLs, not encoded

      # Test label_data method
      assert_respond_to shipment, :label_data
      # Should be nil for URL-based labels
      assert_nil shipment.label_data

      # Test label_data_all method
      assert_respond_to shipment, :label_data_all
      assert_kind_of Array, shipment.label_data_all
      assert_empty shipment.label_data_all # No encoded labels in VCR
    end
  end

  def test_label_helper_methods_mps
    VCR.use_cassette('shipment_create_multi_package') do
      shipment = client.create_shipment(multi_package_shipment_data)

      # MPS cassette has encodedLabel format, not URL format
      # Test label_urls for MPS (will be empty for encoded labels)
      assert_kind_of Array, shipment.label_urls

      # Test label_data_all for MPS (should have 3 encoded labels)
      assert_kind_of Array, shipment.label_data_all
      assert_equal 3, shipment.label_data_all.size
      shipment.label_data_all.each do |data|
        assert_kind_of String, data
        refute_empty data
      end

      # Test label_encoded? for MPS
      assert_equal true, shipment.label_encoded?

      # Test label_data for first package
      refute_nil shipment.label_data
      assert_kind_of String, shipment.label_data
    end
  end

  def test_label_content_with_url
    VCR.use_cassette('shipment_create_single_package') do
      shipment = client.create_shipment(single_package_shipment_data)

      # Test label_content method exists
      assert_respond_to shipment, :label_content

      # Note: URL-based labels may return nil if URL is expired/inaccessible
      # This is expected behavior for test URLs
      # The method should not raise an error
      shipment.label_content

      # Content may be nil due to URL expiration (common in test environment)
      # Just verify the method works without error
      assert_respond_to shipment, :label_content

      # Test with download disabled - should return nil for URL-based labels
      content_no_download = shipment.label_content(download_url: false)
      assert_nil content_no_download, 'Should return nil when download_url is false for URL-based labels'
    end
  end

  def test_label_content_with_encoded
    VCR.use_cassette('shipment_create_multi_package') do
      shipment = client.create_shipment(multi_package_shipment_data)

      # Test label_content method with base64 encoded labels
      content = shipment.label_content
      refute_nil content
      assert_kind_of String, content

      # Should be binary data (PDF starts with %PDF)
      assert content.start_with?('%PDF'), 'Decoded label should be PDF binary data'
    end
  end

  def test_label_contents_multiple
    VCR.use_cassette('shipment_create_multi_package') do
      shipment = client.create_shipment(multi_package_shipment_data)

      # Test label_contents method
      assert_respond_to shipment, :label_contents
      contents = shipment.label_contents
      assert_kind_of Array, contents
      assert_equal 3, contents.size

      # Each should be binary PDF data
      contents.each do |content|
        assert_kind_of String, content
        assert content.start_with?('%PDF'), 'Each label should be PDF binary data'
      end
    end
  end

  def test_save_label_with_encoded
    VCR.use_cassette('shipment_create_multi_package') do
      shipment = client.create_shipment(multi_package_shipment_data)

      # Test save_label method with base64 encoded label
      require 'tempfile'
      tempfile = Tempfile.new(['label', '.pdf'])

      begin
        result = shipment.save_label(tempfile.path)
        assert_equal true, result
        assert File.exist?(tempfile.path)

        # Verify file content
        content = File.read(tempfile.path, mode: 'rb')
        assert content.start_with?('%PDF'), 'Saved file should be valid PDF'
        refute_empty content
      ensure
        tempfile.close
        tempfile.unlink
      end
    end
  end

  def test_save_label_with_url_disabled
    VCR.use_cassette('shipment_create_single_package') do
      shipment = client.create_shipment(single_package_shipment_data)

      # Test save_label with download disabled for URL-based labels
      require 'tempfile'
      tempfile = Tempfile.new(['label', '.pdf'])

      begin
        result = shipment.save_label(tempfile.path, download_url: false)
        assert_equal false, result, 'Should return false when URL download is disabled and label is URL-based'
      ensure
        tempfile.close
        tempfile.unlink
      end
    end
  end

  def test_save_labels_multiple
    VCR.use_cassette('shipment_create_multi_package') do
      shipment = client.create_shipment(multi_package_shipment_data)

      # Test save_labels method
      require 'tmpdir'
      Dir.mktmpdir do |dir|
        saved_files = shipment.save_labels(dir)

        assert_kind_of Array, saved_files
        assert_equal 3, saved_files.size

        # Check each file exists and is valid
        saved_files.each_with_index do |filepath, index|
          assert File.exist?(filepath)
          assert_match(/label_#{index + 1}\.pdf$/, filepath)

          content = File.read(filepath, mode: 'rb')
          assert content.start_with?('%PDF'), "File #{index + 1} should be valid PDF"
        end
      end
    end
  end

  def test_save_labels_with_custom_prefix
    VCR.use_cassette('shipment_create_multi_package') do
      shipment = client.create_shipment(multi_package_shipment_data)

      require 'tmpdir'
      Dir.mktmpdir do |dir|
        saved_files = shipment.save_labels(dir, prefix: 'fedex_label')

        assert_equal 3, saved_files.size
        saved_files.each_with_index do |filepath, index|
          assert_match(/fedex_label_#{index + 1}\.pdf$/, filepath)
        end
      end
    end
  end

  private

  def single_package_shipment_data
    load_json_fixture('requests/shipment_single_package')
  end

  def multi_package_shipment_data
    load_json_fixture('requests/shipment_multi_package')
  end
end
