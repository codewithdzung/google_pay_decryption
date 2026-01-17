# frozen_string_literal: true

module GooglePayDecryption
  module Security
    # Performs constant-time comparison of two strings to prevent timing attacks
    #
    # @param a [String] First string to compare
    # @param b [String] Second string to compare
    # @return [Boolean] true if strings are equal, false otherwise
    def self.secure_compare(a, b)
      # Try to use fast_secure_compare if available
      return FastSecureCompare.compare(a, b) if defined?(FastSecureCompare)

      # Fallback to pure Ruby implementation
      return false unless a.bytesize == b.bytesize

      result = 0
      a.bytes.zip(b.bytes).each do |x, y|
        result |= x ^ y
      end
      result.zero?
    end

    # Generates HKDF (HMAC-based Key Derivation Function) derived key
    #
    # @param key_material [String] The input key material
    # @param info [String] Context and application specific information
    # @param length [Integer] The length of the output key
    # @return [String] The derived key
    def self.hkdf_derive(key_material, info, length)
      require 'openssl'

      # Using HKDF with SHA-256
      # Extract phase (using zero salt as per Google Pay specification)
      hmac = OpenSSL::HMAC.new("\x00" * 32, OpenSSL::Digest.new('SHA256'))
      hmac.update(key_material)
      prk = hmac.digest

      # Expand phase
      output = String.new
      counter = 1
      t = String.new

      while output.bytesize < length
        hmac = OpenSSL::HMAC.new(prk, OpenSSL::Digest.new('SHA256'))
        hmac.update(t + info + [counter].pack('C'))
        t = hmac.digest
        output << t
        counter += 1
      end

      output[0, length]
    end
  end
end
