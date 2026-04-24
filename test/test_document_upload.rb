# frozen_string_literal: true

require 'test_helper'

class TestDocumentUpload < Minitest::Test
  def test_upload_signature_image
    VCR.use_cassette('document_upload_signature') do
      result = client.upload_signature_image(
        signature_fixture_path,
        reference_id: 'ff_signature'
      )

      assert_equal 201, result.status
      assert_predicate result, :success?
      refute_nil result.data
      assert_kind_of Hash, result.data
    end
  end

  def test_upload_letterhead_image
    VCR.use_cassette('document_upload_letterhead') do
      result = client.upload_letterhead_image(
        letterhead_fixture_path,
        reference_id: 'ff_letterhead'
      )

      assert_equal 201, result.status
      assert_predicate result, :success?
      refute_nil result.data
      assert_kind_of Hash, result.data
    end
  end

  def test_upload_document_image_with_explicit_params
    VCR.use_cassette('document_upload_signature') do
      result = client.upload_document_image(
        signature_fixture_path,
        image_type: 'SIGNATURE',
        reference_id: 'ff_signature',
        image_index: 'IMAGE_2',
        content_type: 'image/png'
      )

      assert_equal 201, result.status
      assert_predicate result, :success?
    end
  end

  def test_upload_document_resource_methods
    VCR.use_cassette('document_upload_signature') do
      result = client.upload_signature_image(
        signature_fixture_path,
        reference_id: 'ff_signature'
      )

      assert_respond_to result, :success?
      assert_respond_to result, :errors
      assert_respond_to result, :has_errors?
      assert_respond_to result, :to_h
      assert_respond_to result, :reference_id
      assert_respond_to result, :document_id

      assert_kind_of Hash, result.to_h
      assert_kind_of Array, result.errors
    end
  end

  def test_upload_document_error_handling_file_not_found
    error = assert_raises(ArgumentError) do
      client.upload_signature_image(
        '/tmp/nonexistent_image.png',
        reference_id: 'test_ref'
      )
    end

    assert_match(/File not found/, error.message)
  end

  def test_upload_document_hash_access
    VCR.use_cassette('document_upload_signature') do
      result = client.upload_signature_image(
        signature_fixture_path,
        reference_id: 'ff_signature'
      )

      assert_respond_to result, :[]
      hash = result.to_h

      assert_kind_of Hash, hash
    end
  end

  def test_default_image_index_for_signature
    VCR.use_cassette('document_upload_signature') do
      result = client.upload_document_image(
        signature_fixture_path,
        image_type: 'SIGNATURE',
        reference_id: 'ff_signature'
      )

      assert_predicate result, :success?
    end
  end

  def test_default_image_index_for_letterhead
    VCR.use_cassette('document_upload_letterhead') do
      result = client.upload_document_image(
        letterhead_fixture_path,
        image_type: 'LETTERHEAD',
        reference_id: 'ff_letterhead'
      )

      assert_predicate result, :success?
    end
  end

  private

  def signature_fixture_path
    File.join(FedexApis.root, 'test/fixtures/resources/signature.png')
  end

  def letterhead_fixture_path
    File.join(FedexApis.root, 'test/fixtures/resources/letterhead.png')
  end
end
