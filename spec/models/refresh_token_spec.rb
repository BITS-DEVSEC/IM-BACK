require 'rails_helper'

RSpec.describe RefreshToken, type: :model do
  attributes = [
    { refresh_token: [ :presence ] },
    { expires_at: [ :presence ] },
    { user: [ :belong_to ] }
  ]

  include_examples "model_shared_spec", :refresh_token, attributes

  describe 'uniqueness validation' do
    it 'does not allow duplicate refresh_token values' do
      original = create(:refresh_token)

      # Disable callback for this block only
      RefreshToken.skip_callback(:validation, :before, :set_token_and_expiry, on: :create)

      begin
        duplicate = build(:refresh_token, refresh_token: original.refresh_token)
        expect(duplicate).not_to be_valid
        expect(duplicate.errors[:refresh_token]).to include("has already been taken")
      ensure
        # Re-enable the callback after the test
        RefreshToken.set_callback(:validation, :before, :set_token_and_expiry, on: :create)
      end
    end
  end

  describe 'scopes' do
    describe '.valid' do
      let!(:valid_token)   { create(:refresh_token, expires_at: 2.days.from_now) }
      let!(:expired_token) do
        RefreshToken.skip_callback(:validation, :before, :set_token_and_expiry)
        token = create(:refresh_token, expires_at: 2.days.ago)
        RefreshToken.set_callback(:validation, :before, :set_token_and_expiry)
        token
      end

      it 'returns only non-expired tokens' do
        expect(RefreshToken.valid).to include(valid_token)
        expect(RefreshToken.valid).not_to include(expired_token)
      end
    end

    describe '.for_device' do
      let!(:web_token) { create(:refresh_token, device: 'web') }
      let!(:mobile_token) { create(:refresh_token, device: 'mobile') }

      it 'filters by device name' do
        expect(RefreshToken.for_device('web')).to include(web_token)
        expect(RefreshToken.for_device('web')).not_to include(mobile_token)
      end
    end
  end

  describe 'callbacks' do
    it 'sets token and expiry before validation on create' do
      token = build(:refresh_token, refresh_token: nil, expires_at: nil)
      expect(token.refresh_token).to be_nil
      expect(token.expires_at).to be_nil
      token.valid?
      expect(token.refresh_token).to be_present
      expect(token.expires_at).to be_within(1.minute).of(30.days.from_now)
    end
  end

  describe '#expired?' do
    it 'returns true if token is expired' do
      token = build(:refresh_token, expires_at: 1.hour.ago)
      expect(token.expired?).to be true
    end

    it 'returns false if token is still valid' do
      token = build(:refresh_token, expires_at: 1.hour.from_now)
      expect(token.expired?).to be false
    end
  end

  describe '.generate' do
    let(:user) { create(:user) }
    let(:request) {
      double(
        params: { device_id: 'abc123' },
        remote_ip: '127.0.0.1',
        user_agent: 'RSpec'
      )
    }

    it 'creates a refresh token with expected attributes' do
      token = described_class.generate(user, request)
      expect(token.user).to eq(user)
      expect(token.device).to eq('abc123')
      expect(token.ip_address).to eq('127.0.0.1')
      expect(token.user_agent).to eq('RSpec')
      expect(token.refresh_token).to be_present
      expect(token.expires_at).to be > Time.current
    end
  end
end
