# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-01-17

### Added
- Initial release of GooglePayDecryption gem
- Support for Google Pay token decryption (ECv1 and ECv2 protocols)
- Support for Android Pay token decryption
- Built-in signature verification for Google Pay tokens
- Constant-time comparison for security (with optional fast_secure_compare support)
- HKDF (HMAC-based Key Derivation Function) implementation
- Comprehensive error handling with specific error classes:
  - `GooglePayDecryption::Error` - Base error class
  - `GooglePayDecryption::SignatureError` - Signature verification failures
  - `GooglePayDecryption::ValidationError` - Token validation failures
  - `GooglePayDecryption::DecryptionError` - Decryption failures
  - `GooglePayDecryption::UnsupportedProtocolError` - Unsupported protocol versions
  - `GooglePayDecryption::ConfigurationError` - Configuration errors
- Automatic token type detection (Google Pay vs Android Pay)
- Support for both string and symbol keys in token attributes
- Comprehensive test suite with 36+ test cases
- Detailed documentation and usage examples
- RBS type signatures for type safety

### Features
- **Google Pay**: Full ECv1/ECv2 support with signature verification
- **Android Pay**: AES-GCM decryption support
- **Security**: Constant-time comparison to prevent timing attacks
- **Easy API**: Simple, intuitive interface with `build_token` and `decrypt` methods
- **Well Tested**: 100% coverage of main functionality flows
- **Type Safe**: Includes RBS signatures for better IDE support

### Dependencies
- Ruby >= 2.7.0
- base64 ~> 0.1 (runtime)
- OpenSSL (via Ruby standard library)

### Documentation
- Comprehensive README with multiple examples
- Caching strategies for verification keys
- Error handling best practices
- Security considerations and recommendations
- Performance optimization tips

[Unreleased]: https://github.com/codewithdzung/google_pay_decryption/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/codewithdzung/google_pay_decryption/releases/tag/v0.1.0
