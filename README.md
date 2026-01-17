# GooglePayDecryption

[![Gem Version](https://badge.fury.io/rb/google_pay_decryption.svg)](https://badge.fury.io/rb/google_pay_decryption)
[![Ruby](https://github.com/codewithdzung/google_pay_decryption/actions/workflows/main.yml/badge.svg)](https://github.com/codewithdzung/google_pay_decryption/actions/workflows/main.yml)

A secure, easy-to-use Ruby library for decrypting Google Pay (ECv1/ECv2) and Android Pay payment tokens with built-in signature verification and constant-time comparison for enhanced security.

## Features

- ✅ **Google Pay Support**: Full support for ECv1 and ECv2 protocol versions
- ✅ **Android Pay Support**: Decrypt Android Pay payment tokens
- ✅ **Signature Verification**: Built-in signature verification for Google Pay tokens
- ✅ **Security First**: Constant-time comparison to prevent timing attacks
- ✅ **Well Tested**: Comprehensive test suite with 36+ test cases
- ✅ **Easy to Use**: Simple, intuitive API
- ✅ **Well Documented**: Extensive documentation and examples
- ✅ **Type Safe**: RBS type signatures included

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'google_pay_decryption'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install google_pay_decryption
```

## Ruby Version Support

This gem requires Ruby 2.7.0 or later.

## Usage

### Google Pay Token Decryption

For Google Pay tokens, you need:
- The token JSON from Google Pay
- Your `recipient_id` (provided by Google)
- Google's `verification_keys` for your environment
- Your private key (PEM format)

```ruby
require 'google_pay_decryption'

# Token from Google Pay
token_attrs = {
  "signature" => "MEYCIQD5mAtwoptfXuDnEVvtSbPmRnkw94GXEHjog24SfIe4rAIhAKLeSY4xcHLK1liBoZFaeZG+FrqawI7Id2mJXwddP3KH",
  "protocolVersion" => "ECv1",
  "signedMessage" => "{\"encryptedMessage\":\"jzo38/Ufbt9qh/scrTJmG9v8Cgb7Y5S+zCTTbSou/NoLoE/XF9ixyIGNIspKkH4ulwwVX0/EoqKDKk86XDLw8qBjx1tfHefbLuhZbqkfu/8bs5D6QMz8LjcJU+EeXYcdZ+KeQ3jzrgS6B9CqEJJIF+PeySMJtTwF9Fh+X2sW4Yg0C34mHz0MHpVUpmzJZblTwzMkCVOdq7eMF9Ywb8kDnRFasMYALbRaEOMg2o9gXSfGEVPhS8ors4SRFcnLoVPfktHRJtY/UZEREJvGFY/s/wpmU9sRADYTMKQ/ChTMumT+1NG0r4XibDcaZjW/Wlz1Dwog+dNMYUblPjY613sBLtjoBbRDYYVuDn/TUYXOJwAgXoHFfMmvWm0ne0n9eXggxoaMFFgF5zXk9ZLl3FyH/hi3WWtsFt5sqQWgFdjsqTriL6i46m46hMaZ9gKZ8JQE912IG5kZts5L8XSMiG94Z3UiTA\\u003d\\u003d\",\"ephemeralPublicKey\":\"BIeq42AvLcEhz0oLmYdj++oBTS5PD131FAEgx4y91cwqbkZMUKADkzj2bD4MxneqgqFYirO29+y/G6YH9zmfjlk\\u003d\",\"tag\":\"sRILsawzbm53+9tVTh9ooBP5ivzxWki73UJbuOZ3IYY\\u003d\"}"
}

# Your recipient ID from Google
recipient_id = "merchant:12345678901234567890"
# or
recipient_id = "gateway:gateway_name"

# Fetch verification keys from Google
# Production: https://payments.developers.google.com/paymentmethodtoken/keys.json
# Test: https://payments.developers.google.com/paymentmethodtoken/test/keys.json
verification_keys = {
  "keys" => [
    {
      "keyValue" => "MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEIsFro6K+IUxRr4yFTOTO+kFCCEvHo7B9IOMLxah6c977oFzX/beObH4a9OfosMHmft3JJZ6B3xpjIb8kduK4/A==",
      "protocolVersion" => "ECv1"
    }
  ]
}

# Load your private key
private_key_pem = File.read('path/to/your/private_key.pem')

# Method 1: Build token and decrypt
token = GooglePayDecryption.build_token(
  token_attrs,
  recipient_id: recipient_id,
  verification_keys: verification_keys
)

decrypted_json = token.decrypt(private_key_pem)
payment_data = JSON.parse(decrypted_json)

# Method 2: One-step decryption
decrypted_json = GooglePayDecryption.decrypt(
  token_attrs,
  private_key_pem,
  recipient_id: recipient_id,
  verification_keys: verification_keys
)

# Decrypted payment data structure:
# {
#   "gatewayMerchantId" => "exampleGatewayMerchantId",
#   "messageExpiration" => "1528716120231",
#   "messageId" => "AH2EjtcpVGS3JvxlTP5kUbx3h0Laa30uVKjB9CqmnYiw8gZ-tpsxIoOdTbAU_DtCbkLVUPzkFeeqSbU1vTbAIAE4LlPHJqBiMMF4hZ5KRafml3764_6lK7aH7cQkIma40CI-rtCWTLCk",
#   "paymentMethod" => "CARD",
#   "paymentMethodDetails" => {
#     "expirationYear" => 2023,
#     "expirationMonth" => 12,
#     "pan" => "4111111111111111"
#   }
# }
```

### Android Pay Token Decryption

For Android Pay tokens, you only need:
- The token JSON from Android Pay
- Your private key (PEM format)

```ruby
require 'google_pay_decryption'

# Token from Android Pay
token_attrs = {
  "encryptedMessage" => "ZW5jcnlwdGVkTWVzc2FnZQ==",
  "ephemeralPublicKey" => "ZXBoZW1lcmFsUHVibGljS2V5",
  "tag" => "c2lnbmF0dXJl"
}

# Load your private key
private_key_pem = File.read('path/to/your/private_key.pem')

# Method 1: Build token and decrypt
token = GooglePayDecryption.build_token(token_attrs)
decrypted_json = token.decrypt(private_key_pem)

# Method 2: One-step decryption
decrypted_json = GooglePayDecryption.decrypt(token_attrs, private_key_pem)

payment_data = JSON.parse(decrypted_json)

# Decrypted payment data structure:
# {
#   "dpan" => "4444444444444444",
#   "expirationMonth" => 10,
#   "expirationYear" => 2015,
#   "authMethod" => "3DS",
#   "3dsCryptogram" => "AAAAAA...",
#   "3dsEciIndicator" => "eci indicator"
# }
```

### Caching Verification Keys

It's recommended to cache Google's verification keys for performance and resiliency:

```ruby
class GooglePayService
  VERIFICATION_KEYS_URL = {
    production: 'https://payments.developers.google.com/paymentmethodtoken/keys.json',
    test: 'https://payments.developers.google.com/paymentmethodtoken/test/keys.json'
  }.freeze

  def initialize(environment: :production)
    @environment = environment
    @verification_keys = nil
    @keys_expires_at = nil
  end

  def verification_keys
    refresh_keys_if_needed
    @verification_keys
  end

  def decrypt_token(token_attrs, recipient_id:, private_key_pem:)
    GooglePayDecryption.decrypt(
      token_attrs,
      private_key_pem,
      recipient_id: recipient_id,
      verification_keys: verification_keys
    )
  end

  private

  def refresh_keys_if_needed
    if @verification_keys.nil? || Time.now >= @keys_expires_at
      fetch_verification_keys
    end
  end

  def fetch_verification_keys
    require 'net/http'
    require 'json'

    uri = URI(VERIFICATION_KEYS_URL[@environment])
    response = Net::HTTP.get_response(uri)
    
    if response.is_a?(Net::HTTPSuccess)
      @verification_keys = JSON.parse(response.body)
      
      # Parse Cache-Control header
      cache_control = response['cache-control']
      max_age = cache_control&.match(/max-age=(\d+)/)&.[](1)&.to_i || 3600
      
      # Refresh proactively at half the max-age (as recommended by Google)
      @keys_expires_at = Time.now + (max_age / 2)
    else
      raise "Failed to fetch verification keys: #{response.code}"
    end
  end
end

# Usage
service = GooglePayService.new(environment: :test)
decrypted_data = service.decrypt_token(
  token_attrs,
  recipient_id: 'merchant:123456',
  private_key_pem: private_key_pem
)
```

## Error Handling

The gem provides specific error classes for different failure scenarios:

```ruby
begin
  token = GooglePayDecryption.build_token(
    token_attrs,
    recipient_id: recipient_id,
    verification_keys: verification_keys
  )
  decrypted_data = token.decrypt(private_key_pem)
rescue GooglePayDecryption::SignatureError => e
  # Signature verification failed
  puts "Invalid signature: #{e.message}"
rescue GooglePayDecryption::ValidationError => e
  # Token validation failed (missing fields, invalid format)
  puts "Invalid token: #{e.message}"
rescue GooglePayDecryption::DecryptionError => e
  # Decryption failed
  puts "Decryption failed: #{e.message}"
rescue GooglePayDecryption::UnsupportedProtocolError => e
  # Unsupported protocol version
  puts "Unsupported protocol: #{e.message}"
rescue GooglePayDecryption::ConfigurationError => e
  # Configuration error (missing recipient_id or verification_keys)
  puts "Configuration error: #{e.message}"
rescue GooglePayDecryption::Error => e
  # Base error class - catches all gem errors
  puts "Error: #{e.message}"
end
```

## Performance

The library implements constant-time comparison for security, but the pure Ruby implementation can be slow. For better performance, add `fast_secure_compare` to your Gemfile:

```ruby
gem 'fast_secure_compare'
```

Benchmarks (comparing two 32-byte strings 100,000 times):

| Implementation | Time |
|----------------|------|
| Pure Ruby | ~1.2s |
| fast_secure_compare | ~0.05s |

The gem automatically uses `fast_secure_compare` if available, with no code changes required.

## Security Considerations

1. **Private Key Storage**: Never commit your private key to version control. Use environment variables or a secure key management system.

2. **Verification Keys**: Always fetch verification keys from Google's official endpoints and respect the cache control headers.

3. **Token Validation**: The gem validates token structure and signature before decryption.

4. **Timing Attacks**: The gem uses constant-time comparison to prevent timing attacks on signature verification.

5. **Protocol Versions**: Only ECv1 and ECv2 are currently supported. The gem will reject unsupported protocol versions.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bundle exec rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Testing

Run the test suite:

```bash
bundle exec rspec
```

Run with coverage:

```bash
COVERAGE=true bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/codewithdzung/google_pay_decryption. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/codewithdzung/google_pay_decryption/blob/main/CODE_OF_CONDUCT.md).

### How to Contribute

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Write tests for your changes
4. Make your changes and ensure tests pass
5. Commit your changes (`git commit -m 'Add some amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the GooglePayDecryption project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/codewithdzung/google_pay_decryption/blob/main/CODE_OF_CONDUCT.md).

## Credits

Inspired by [r2d2](https://github.com/begateway/r2d2) but with:
- Better error handling with specific error types
- Improved documentation and examples
- More comprehensive test suite
- Support for both ECv1 and ECv2 protocols
- Better structured code with clear separation of concerns
- Modern Ruby practices and coding standards

## Resources

- [Google Pay Web Integration Guide](https://developers.google.com/pay/api/web/guides/tutorial)
- [Payment Token Decryption](https://developers.google.com/pay/api/web/guides/resources/payment-data-cryptography)
- [Payment Method Token Specification](https://developers.google.com/pay/api/web/guides/resources/payment-method-token-specification)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.

## Support

If you have questions or need help, please:
1. Check the documentation above
2. Search existing [GitHub issues](https://github.com/codewithdzung/google_pay_decryption/issues)
3. Open a new issue if your question hasn't been answered

---

**Author**: Nguyen Tien Dzung ([@codewithdzung](https://github.com/codewithdzung))  
**Email**: imnguyentiendzung@gmail.com
