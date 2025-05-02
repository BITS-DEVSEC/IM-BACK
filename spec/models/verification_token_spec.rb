require 'rails_helper'

RSpec.describe VerificationToken, type: :model do
  attributes = [
    { token: [ :presence ] },
    { token_type: [ :presence ] },
    { expires_at: [ :presence ] },
    { user: [ :belong_to ] }
  ]

  include_examples "model_shared_spec", :verification_token, attributes

  describe 'methods' do
    subject { create(:verification_token) }

    describe '#expired?' do
      it 'returns true when token is expired' do
        subject.expires_at = 1.hour.ago
        expect(subject.expired?).to be true
      end

      it 'returns false when token is not expired' do
        subject.expires_at = 1.hour.from_now
        expect(subject.expired?).to be false
      end
    end

    describe '#generate_token' do
      it 'generates a token before validation' do
        token = build(:verification_token, token: nil)
        expect(token.token).to be_nil
        token.valid?
        expect(token.token).not_to be_nil
      end

      it 'sets expiration time' do
        token = build(:verification_token, expires_at: nil)
        expect(token.expires_at).to be_nil
        token.valid?
        expect(token.expires_at).to be_present
      end
    end
  end
end
