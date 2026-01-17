# frozen_string_literal: true

RSpec.describe GooglePayDecryption do
  it 'has a version number' do
    expect(GooglePayDecryption::VERSION).not_to be nil
  end

  describe '.build_token' do
    context 'with Google Pay token attributes' do
      let(:token_attrs) do
        {
          'protocolVersion' => 'ECv1',
          'signature' => 'base64signature',
          'signedMessage' => '{"encryptedMessage":"test"}'
        }
      end

      let(:options) do
        {
          recipient_id: 'merchant:123456',
          verification_keys: [{ 'protocolVersion' => 'ECv1', 'keyValue' => 'key' }]
        }
      end

      it 'returns a GooglePayToken' do
        token = GooglePayDecryption.build_token(token_attrs, **options)
        expect(token).to be_a(GooglePayDecryption::GooglePayToken)
      end

      it 'accepts symbol keys' do
        symbol_attrs = token_attrs.transform_keys(&:to_sym)
        token = GooglePayDecryption.build_token(symbol_attrs, **options)
        expect(token).to be_a(GooglePayDecryption::GooglePayToken)
      end
    end

    context 'with Android Pay token attributes' do
      let(:token_attrs) do
        {
          'encryptedMessage' => 'base64encryptedmessage',
          'ephemeralPublicKey' => 'base64publickey',
          'tag' => 'base64tag'
        }
      end

      it 'returns an AndroidPayToken' do
        token = GooglePayDecryption.build_token(token_attrs)
        expect(token).to be_a(GooglePayDecryption::AndroidPayToken)
      end
    end
  end

  describe '.decrypt' do
    it 'delegates to token decrypt method' do
      token_attrs = {
        'encryptedMessage' => 'test',
        'ephemeralPublicKey' => 'test',
        'tag' => 'test'
      }

      token = instance_double(GooglePayDecryption::AndroidPayToken)
      allow(GooglePayDecryption).to receive(:build_token).and_return(token)
      allow(token).to receive(:decrypt).and_return('{"result":"success"}')

      result = GooglePayDecryption.decrypt(token_attrs, 'private_key_pem')
      expect(result).to eq('{"result":"success"}')
    end
  end
end
