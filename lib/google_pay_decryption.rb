# frozen_string_literal: true

require_relative "google_pay_decryption/version"
require_relative "google_pay_decryption/errors"
require_relative "google_pay_decryption/security"
require_relative "google_pay_decryption/token"
require_relative "google_pay_decryption/google_pay_token"
require_relative "google_pay_decryption/android_pay_token"

module GooglePayDecryption
  # Build a token from the given attributes
  #
  # @param token_attrs [Hash] The token attributes from Google Pay or Android Pay
  # @param options [Hash] Additional options for Google Pay tokens
  # @option options [String] :recipient_id The merchant/gateway recipient ID (required for Google Pay)
  # @option options [Array<Hash>] :verification_keys Google's verification keys (required for Google Pay)
  # @return [GooglePayToken, AndroidPayToken] The token object
  #
  # @example Google Pay token
  #   token = GooglePayDecryption.build_token(
  #     token_attrs,
  #     recipient_id: 'merchant:12345678901234567890',
  #     verification_keys: verification_keys
  #   )
  #
  # @example Android Pay token
  #   token = GooglePayDecryption.build_token(token_attrs)
  def self.build_token(token_attrs, **options)
    token_attrs = symbolize_keys(token_attrs)
    
    if google_pay_token?(token_attrs)
      GooglePayToken.new(token_attrs, **options)
    else
      AndroidPayToken.new(token_attrs)
    end
  end

  # Decrypt a token with the given private key
  #
  # @param token_attrs [Hash] The token attributes
  # @param private_key_pem [String] The private key in PEM format
  # @param options [Hash] Additional options for Google Pay tokens
  # @return [String] The decrypted JSON string
  def self.decrypt(token_attrs, private_key_pem, **options)
    token = build_token(token_attrs, **options)
    token.decrypt(private_key_pem)
  end

  private

  def self.google_pay_token?(token_attrs)
    token_attrs.key?(:protocolVersion) || token_attrs.key?('protocolVersion')
  end

  def self.symbolize_keys(hash)
    return hash unless hash.is_a?(Hash)
    
    hash.transform_keys do |key|
      key.is_a?(String) ? key.to_sym : key
    end
  end
end
