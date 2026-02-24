## [Unreleased]

### Added
- FedEx Ship API support for creating, validating, and canceling shipments
- `Client#create_shipment(params)` - Create shipments with single or multiple packages
- `Client#validate_shipment(params)` - Validate shipment parameters before creation
- `Client#cancel_shipment(tracking_number)` - Cancel existing shipments
- `Resource::Shipment` with convenience methods:
  - `tracking_number` / `tracking_numbers` - Easy access to tracking information
  - `master_tracking_number` - For multi-package shipments (MPS)
  - **Consistent Label Interface** (handles both URL and base64 formats automatically):
    - `label_content` / `label_contents` - Get label(s) as binary data
    - `save_label(path)` - Save label to file
    - `save_labels(directory)` - Save all labels to directory (MPS)
  - Low-level label access:
    - `label` / `labels` - Access to raw shipping label objects
    - `label_url` / `label_urls` - Direct access to label URLs
    - `label_encoded?` - Check if labels are base64 encoded
    - `label_data` / `label_data_all` - Access to base64 encoded label data
  - `documents` / `document(type)` - Access to all shipping documents
  - `alerts` / `errors` - Error and alert handling
- Full support for Multi-Package Shipments (MPS) with up to multiple packages
- Consistent interface that handles FedEx API label format inconsistencies (URL vs base64)
- Automatic label download and base64 decoding - just call `save_label()` or `label_content`
- Pass-through parameter approach - use any FedEx API parameter without gem updates
- Comprehensive test coverage with VCR cassettes (20 tests, 163 assertions)
- Example file demonstrating shipment creation, validation, and cancellation
- Automatic credential loading from .env file using dotenv gem

## [0.1.0] - 2023-05-11

- Initial release
