# frozen_string_literal: true

require 'spec_helper'

RSpec.describe GooglePayDecryption::Security do
  describe '.secure_compare' do
    it 'returns true for identical strings' do
      expect(described_class.secure_compare('hello', 'hello')).to be true
    end

    it 'returns false for different strings' do
      expect(described_class.secure_compare('hello', 'world')).to be false
    end

    it 'returns false for strings of different lengths' do
      expect(described_class.secure_compare('hello', 'hello world')).to be false
    end

    it 'returns true for empty strings' do
      expect(described_class.secure_compare('', '')).to be true
    end

    it 'handles binary data correctly' do
      data1 = "\x00\x01\x02\x03"
      data2 = "\x00\x01\x02\x03"
      data3 = "\x00\x01\x02\x04"

      expect(described_class.secure_compare(data1, data2)).to be true
      expect(described_class.secure_compare(data1, data3)).to be false
    end
  end

  describe '.hkdf_derive' do
    it 'derives a key of specified length' do
      key_material = 'shared_secret'
      info = 'context_info'
      length = 32

      derived_key = described_class.hkdf_derive(key_material, info, length)
      expect(derived_key.bytesize).to eq(length)
    end

    it 'produces different keys for different info' do
      key_material = 'shared_secret'
      key1 = described_class.hkdf_derive(key_material, 'info1', 32)
      key2 = described_class.hkdf_derive(key_material, 'info2', 32)

      expect(key1).not_to eq(key2)
    end

    it 'produces consistent results for same inputs' do
      key_material = 'shared_secret'
      info = 'context_info'
      
      key1 = described_class.hkdf_derive(key_material, info, 32)
      key2 = described_class.hkdf_derive(key_material, info, 32)

      expect(key1).to eq(key2)
    end

    it 'can derive keys longer than hash output' do
      key_material = 'shared_secret'
      info = 'context_info'
      length = 100 # Longer than SHA256 output (32 bytes)

      derived_key = described_class.hkdf_derive(key_material, info, length)
      expect(derived_key.bytesize).to eq(length)
    end
  end
end
