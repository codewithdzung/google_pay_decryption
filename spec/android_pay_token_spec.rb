# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GooglePayDecryption::AndroidPayToken do
  describe '#initialize' do
    it 'accepts valid token attributes' do
      token_attrs = {
        encryptedMessage: Base64.strict_encode64('encrypted'),
        ephemeralPublicKey: Base64.strict_encode64('publickey'),
        tag: Base64.strict_encode64('tag')
      }

      expect { described_class.new(token_attrs) }.not_to raise_error
    end

    it 'raises ValidationError when missing encryptedMessage' do
      token_attrs = {
        ephemeralPublicKey: Base64.strict_encode64('publickey'),
        tag: Base64.strict_encode64('tag')
      }

      expect { described_class.new(token_attrs) }
        .to raise_error(GooglePayDecryption::ValidationError, /encryptedMessage/)
    end

    it 'raises ValidationError when missing ephemeralPublicKey' do
      token_attrs = {
        encryptedMessage: Base64.strict_encode64('encrypted'),
        tag: Base64.strict_encode64('tag')
      }

      expect { described_class.new(token_attrs) }
        .to raise_error(GooglePayDecryption::ValidationError, /ephemeralPublicKey/)
    end

    it 'raises ValidationError when missing tag' do
      token_attrs = {
        encryptedMessage: Base64.strict_encode64('encrypted'),
        ephemeralPublicKey: Base64.strict_encode64('publickey')
      }

      expect { described_class.new(token_attrs) }
        .to raise_error(GooglePayDecryption::ValidationError, /tag/)
    end
  end

  describe '#decrypt' do
    it 'raises DecryptionError with invalid private key' do
      token_attrs = {
        encryptedMessage: Base64.strict_encode64('encrypted'),
        ephemeralPublicKey: Base64.strict_encode64('publickey'),
        tag: Base64.strict_encode64('tag')
      }

      token = described_class.new(token_attrs)

      expect { token.decrypt('invalid_key') }
        .to raise_error(GooglePayDecryption::DecryptionError, /Invalid private key/)
    end

    it 'raises DecryptionError with invalid base64 encoding' do
      token_attrs = {
        encryptedMessage: 'not-valid-base64!!!',
        ephemeralPublicKey: Base64.strict_encode64('publickey'),
        tag: Base64.strict_encode64('tag')
      }

      expect { described_class.new(token_attrs) }
        .not_to raise_error # Validation happens during decrypt

      token = described_class.new(token_attrs)
      private_key = OpenSSL::PKey::EC.generate('prime256v1')

      expect { token.decrypt(private_key.to_pem) }
        .to raise_error(GooglePayDecryption::DecryptionError, /Invalid base64 encoding/)
    end
  end
end
