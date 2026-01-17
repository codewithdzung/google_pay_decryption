# frozen_string_literal: true

module GooglePayDecryption
  # Base error class for all GooglePayDecryption errors
  class Error < StandardError; end

  # Raised when token signature verification fails
  class SignatureError < Error; end

  # Raised when token validation fails
  class ValidationError < Error; end

  # Raised when decryption fails
  class DecryptionError < Error; end

  # Raised when the protocol version is not supported
  class UnsupportedProtocolError < Error; end

  # Raised when configuration is invalid
  class ConfigurationError < Error; end
end
