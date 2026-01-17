# frozen_string_literal: true

module GooglePayDecryption
  # Represents an Android Pay payment token
  class AndroidPayToken < Token
    REQUIRED_FIELDS = %i[encryptedMessage ephemeralPublicKey tag].freeze

    def decrypt(private_key_pem)
      private_key = load_private_key(private_key_pem)

      encrypted_message = decode_base64(token_attrs[:encryptedMessage])
      ephemeral_public_key = decode_base64(token_attrs[:ephemeralPublicKey])
      tag = decode_base64(token_attrs[:tag])

      # Load ephemeral public key
      ephemeral_key = load_ephemeral_key(ephemeral_public_key)

      # Perform ECDH to derive shared secret
      shared_secret = private_key.dh_compute_key(ephemeral_key.public_key)

      # Derive symmetric key using HKDF
      symmetric_key = Security.hkdf_derive(shared_secret, 'Android', 32)

      # Decrypt the message using AES-256-GCM
      decrypt_aes_gcm(encrypted_message, symmetric_key, tag)
    rescue StandardError => e
      raise DecryptionError, "Failed to decrypt Android Pay token: #{e.message}"
    end

    protected

    def validate!
      REQUIRED_FIELDS.each do |field|
        raise ValidationError, "Missing required field: #{field}" unless token_attrs.key?(field)
      end
    end

    private

    def load_ephemeral_key(ephemeral_public_key_bytes)
      group = OpenSSL::PKey::EC::Group.new('prime256v1')
      key = OpenSSL::PKey::EC.new(group)

      # The ephemeral public key is in uncompressed format (0x04 prefix + x + y coordinates)
      point = OpenSSL::PKey::EC::Point.new(group, OpenSSL::BN.new(ephemeral_public_key_bytes, 2))
      key.public_key = point
      key
    rescue StandardError => e
      raise ValidationError, "Invalid ephemeral public key: #{e.message}"
    end

    def decrypt_aes_gcm(encrypted_data, key, tag)
      cipher = OpenSSL::Cipher.new('aes-256-gcm')
      cipher.decrypt
      cipher.key = key
      cipher.iv = "\x00" * 12 # 96-bit zero IV
      cipher.auth_tag = tag
      cipher.auth_data = '' # Empty associated data

      cipher.update(encrypted_data) + cipher.final
    rescue StandardError => e
      raise DecryptionError, "AES-GCM decryption failed: #{e.message}"
    end
  end
end
