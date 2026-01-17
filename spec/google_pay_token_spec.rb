# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GooglePayDecryption::GooglePayToken do
  let(:verification_keys) do
    [
      {
        'protocolVersion' => 'ECv1',
        'keyValue' => Base64.strict_encode64('dummy_key')
      }
    ]
  end

  describe '#initialize' do
    it 'accepts valid token attributes' do
      token_attrs = {
        signature: Base64.strict_encode64('signature'),
        protocolVersion: 'ECv1',
        signedMessage: '{"encryptedMessage":"test"}'
      }

      expect do
        described_class.new(
          token_attrs,
          recipient_id: 'merchant:123456',
          verification_keys: verification_keys
        )
      end.not_to raise_error
    end

    it 'raises ValidationError when missing signature' do
      token_attrs = {
        protocolVersion: 'ECv1',
        signedMessage: '{"encryptedMessage":"test"}'
      }

      expect do
        described_class.new(
          token_attrs,
          recipient_id: 'merchant:123456',
          verification_keys: verification_keys
        )
      end.to raise_error(GooglePayDecryption::ValidationError, /signature/)
    end

    it 'raises ValidationError when missing protocolVersion' do
      token_attrs = {
        signature: Base64.strict_encode64('signature'),
        signedMessage: '{"encryptedMessage":"test"}'
      }

      expect do
        described_class.new(
          token_attrs,
          recipient_id: 'merchant:123456',
          verification_keys: verification_keys
        )
      end.to raise_error(GooglePayDecryption::ValidationError, /protocolVersion/)
    end

    it 'raises UnsupportedProtocolError for unsupported protocol version' do
      token_attrs = {
        signature: Base64.strict_encode64('signature'),
        protocolVersion: 'ECv3',
        signedMessage: '{"encryptedMessage":"test"}'
      }

      expect do
        described_class.new(
          token_attrs,
          recipient_id: 'merchant:123456',
          verification_keys: verification_keys
        )
      end.to raise_error(GooglePayDecryption::UnsupportedProtocolError, /ECv3/)
    end

    it 'raises ConfigurationError when recipient_id is missing' do
      token_attrs = {
        signature: Base64.strict_encode64('signature'),
        protocolVersion: 'ECv1',
        signedMessage: '{"encryptedMessage":"test"}'
      }

      expect do
        described_class.new(
          token_attrs,
          verification_keys: verification_keys
        )
      end.to raise_error(GooglePayDecryption::ConfigurationError, /recipient_id/)
    end

    it 'raises ConfigurationError when verification_keys are missing' do
      token_attrs = {
        signature: Base64.strict_encode64('signature'),
        protocolVersion: 'ECv1',
        signedMessage: '{"encryptedMessage":"test"}'
      }

      expect do
        described_class.new(
          token_attrs,
          recipient_id: 'merchant:123456'
        )
      end.to raise_error(GooglePayDecryption::ConfigurationError, /verification_keys/)
    end

    it 'supports ECv2 protocol' do
      token_attrs = {
        signature: Base64.strict_encode64('signature'),
        protocolVersion: 'ECv2',
        signedMessage: '{"encryptedMessage":"test"}'
      }

      verification_keys_v2 = [
        {
          'protocolVersion' => 'ECv2',
          'keyValue' => Base64.strict_encode64('dummy_key')
        }
      ]

      expect do
        described_class.new(
          token_attrs,
          recipient_id: 'merchant:123456',
          verification_keys: verification_keys_v2
        )
      end.not_to raise_error
    end
  end

  describe 'attribute accessors' do
    it 'provides access to recipient_id' do
      token_attrs = {
        signature: Base64.strict_encode64('signature'),
        protocolVersion: 'ECv1',
        signedMessage: '{"encryptedMessage":"test"}'
      }

      token = described_class.new(
        token_attrs,
        recipient_id: 'merchant:123456',
        verification_keys: verification_keys
      )

      expect(token.recipient_id).to eq('merchant:123456')
    end

    it 'provides access to verification_keys' do
      token_attrs = {
        signature: Base64.strict_encode64('signature'),
        protocolVersion: 'ECv1',
        signedMessage: '{"encryptedMessage":"test"}'
      }

      token = described_class.new(
        token_attrs,
        recipient_id: 'merchant:123456',
        verification_keys: verification_keys
      )

      expect(token.verification_keys).to eq(verification_keys)
    end
  end
end
