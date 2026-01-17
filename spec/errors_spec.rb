# frozen_string_literal: true

require 'spec_helper'

RSpec.describe 'GooglePayDecryption Error Classes' do
  it 'defines base Error class' do
    expect(GooglePayDecryption::Error).to be < StandardError
  end

  it 'defines SignatureError' do
    expect(GooglePayDecryption::SignatureError).to be < GooglePayDecryption::Error
  end

  it 'defines ValidationError' do
    expect(GooglePayDecryption::ValidationError).to be < GooglePayDecryption::Error
  end

  it 'defines DecryptionError' do
    expect(GooglePayDecryption::DecryptionError).to be < GooglePayDecryption::Error
  end

  it 'defines UnsupportedProtocolError' do
    expect(GooglePayDecryption::UnsupportedProtocolError).to be < GooglePayDecryption::Error
  end

  it 'defines ConfigurationError' do
    expect(GooglePayDecryption::ConfigurationError).to be < GooglePayDecryption::Error
  end

  it 'allows raising with custom message' do
    expect { raise GooglePayDecryption::ValidationError, 'Custom error message' }
      .to raise_error(GooglePayDecryption::ValidationError, 'Custom error message')
  end
end
