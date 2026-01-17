# frozen_string_literal: true

require 'openssl'
require 'base64'
require 'json'

module GooglePayDecryption
  # Base class for payment tokens
  class Token
    attr_reader :token_attrs

    def initialize(token_attrs)
      @token_attrs = token_attrs
      validate!
    end

    # Decrypt the token with the given private key
    #
    # @param private_key_pem [String] The private key in PEM format
    # @return [String] The decrypted JSON string
    # @raise [DecryptionError] If decryption fails
    def decrypt(private_key_pem)
      raise NotImplementedError, 'Subclass must implement decrypt method'
    end

    protected

    def validate!
      raise NotImplementedError, 'Subclass must implement validate! method'
    end

    def load_private_key(private_key_pem)
      OpenSSL::PKey::EC.new(private_key_pem)
    rescue StandardError => e
      raise DecryptionError, "Invalid private key: #{e.message}"
    end

    def decode_base64(data)
      Base64.strict_decode64(data)
    rescue ArgumentError => e
      raise ValidationError, "Invalid base64 encoding: #{e.message}"
    end
  end
end
