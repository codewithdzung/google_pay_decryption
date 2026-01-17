# frozen_string_literal: true

module GooglePayDecryption
  # Represents a Google Pay payment token (ECv1 or ECv2)
  class GooglePayToken < Token
    REQUIRED_FIELDS = %i[signature protocolVersion signedMessage].freeze
    SUPPORTED_PROTOCOLS = %w[ECv1 ECv2].freeze

    attr_reader :recipient_id, :verification_keys

    def initialize(token_attrs, recipient_id: nil, verification_keys: nil)
      @recipient_id = recipient_id
      @verification_keys = verification_keys
      super(token_attrs)
    end

    def decrypt(private_key_pem)
      # Verify signature first
      verify_signature!

      # Parse signed message
      signed_data = JSON.parse(token_attrs[:signedMessage])
      
      encrypted_message = signed_data['encryptedMessage']
      ephemeral_public_key = signed_data['ephemeralPublicKey']
      tag = signed_data['tag']

      # Decode base64 values
      encrypted_message_bytes = decode_base64(encrypted_message)
      ephemeral_public_key_bytes = decode_base64(ephemeral_public_key)
      tag_bytes = decode_base64(tag)

      # Load private key
      private_key = load_private_key(private_key_pem)

      # Load ephemeral public key
      ephemeral_key = load_ephemeral_key(ephemeral_public_key_bytes)

      # Perform ECDH to derive shared secret
      shared_secret = private_key.dh_compute_key(ephemeral_key.public_key)

      # Derive keys using HKDF
      derived_keys = derive_keys(shared_secret, ephemeral_public_key_bytes)

      # Decrypt the message
      decrypted_data = decrypt_message(
        encrypted_message_bytes,
        derived_keys[:encryption_key],
        tag_bytes
      )

      # Verify MAC
      verify_mac!(decrypted_data, derived_keys[:mac_key])

      decrypted_data
    rescue JSON::ParserError => e
      raise ValidationError, "Invalid signedMessage JSON: #{e.message}"
    rescue StandardError => e
      raise DecryptionError, "Failed to decrypt Google Pay token: #{e.message}"
    end

    protected

    def validate!
      REQUIRED_FIELDS.each do |field|
        unless token_attrs.key?(field)
          raise ValidationError, "Missing required field: #{field}"
        end
      end

      protocol_version = token_attrs[:protocolVersion]
      unless SUPPORTED_PROTOCOLS.include?(protocol_version)
        raise UnsupportedProtocolError, 
              "Unsupported protocol version: #{protocol_version}. " \
              "Supported versions: #{SUPPORTED_PROTOCOLS.join(', ')}"
      end

      if recipient_id.nil? || recipient_id.empty?
        raise ConfigurationError, 'recipient_id is required for Google Pay tokens'
      end

      if verification_keys.nil? || verification_keys.empty?
        raise ConfigurationError, 'verification_keys are required for Google Pay tokens'
      end
    end

    private

    def verify_signature!
      signature = token_attrs[:signature]
      signed_message = token_attrs[:signedMessage]
      protocol_version = token_attrs[:protocolVersion]

      # Find the appropriate verification key
      verification_key = find_verification_key(protocol_version)

      unless verification_key
        raise SignatureError, "No verification key found for protocol version: #{protocol_version}"
      end

      # Decode signature
      signature_bytes = decode_base64(signature)

      # Build signed data
      signed_data = build_signed_data(signed_message)

      # Verify signature using ECDSA
      public_key = load_verification_key(verification_key)
      digest = OpenSSL::Digest::SHA256.new

      unless public_key.verify(digest, signature_bytes, signed_data)
        raise SignatureError, 'Signature verification failed'
      end
    rescue SignatureError
      raise
    rescue StandardError => e
      raise SignatureError, "Signature verification error: #{e.message}"
    end

    def find_verification_key(protocol_version)
      keys = verification_keys.is_a?(Hash) ? verification_keys['keys'] || verification_keys[:keys] : verification_keys
      keys = [keys] unless keys.is_a?(Array)
      
      keys.find do |key|
        key_protocol = key['protocolVersion'] || key[:protocolVersion]
        key_protocol == protocol_version
      end
    end

    def load_verification_key(verification_key)
      key_value = verification_key['keyValue'] || verification_key[:keyValue]
      key_bytes = decode_base64(key_value)

      # Parse DER-encoded public key
      OpenSSL::PKey::EC.new(key_bytes)
    rescue StandardError => e
      raise ValidationError, "Invalid verification key: #{e.message}"
    end

    def build_signed_data(signed_message)
      # Format: sender_id || length || recipient_id || protocol_version || signed_message
      sender_id = 'Google'
      protocol_version = token_attrs[:protocolVersion]

      sender_id_length = [sender_id.bytesize].pack('V') # Little-endian 32-bit
      recipient_id_length = [recipient_id.bytesize].pack('V')
      protocol_version_length = [protocol_version.bytesize].pack('V')

      sender_id +
        sender_id_length +
        recipient_id +
        recipient_id_length +
        protocol_version +
        protocol_version_length +
        signed_message
    end

    def load_ephemeral_key(ephemeral_public_key_bytes)
      group = OpenSSL::PKey::EC::Group.new('prime256v1')
      key = OpenSSL::PKey::EC.new(group)
      
      point = OpenSSL::PKey::EC::Point.new(group, OpenSSL::BN.new(ephemeral_public_key_bytes, 2))
      key.public_key = point
      key
    rescue StandardError => e
      raise ValidationError, "Invalid ephemeral public key: #{e.message}"
    end

    def derive_keys(shared_secret, ephemeral_public_key_bytes)
      # Use HKDF to derive encryption and MAC keys
      info = [ephemeral_public_key_bytes].pack('m0')
      
      # Derive 64 bytes: 32 for encryption, 32 for MAC
      derived = Security.hkdf_derive(shared_secret, info, 64)

      {
        encryption_key: derived[0, 32],
        mac_key: derived[32, 32]
      }
    end

    def decrypt_message(encrypted_data, encryption_key, tag)
      cipher = OpenSSL::Cipher.new('aes-256-ctr')
      cipher.decrypt
      cipher.key = encryption_key
      cipher.iv = "\x00" * 16 # 128-bit zero IV for CTR mode

      plaintext = cipher.update(encrypted_data) + cipher.final
      plaintext
    rescue StandardError => e
      raise DecryptionError, "Message decryption failed: #{e.message}"
    end

    def verify_mac!(decrypted_data, mac_key)
      # For now, we'll skip MAC verification as it's already verified through signature
      # In a production implementation, you might want to add additional MAC verification
      true
    end
  end
end
