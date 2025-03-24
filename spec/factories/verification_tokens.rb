FactoryBot.define do
  factory :verification_token do
    association :user
    token { SecureRandom.hex(32) }
    token_type { :email } # Default to :email, but can be overridden
    expires_at { 30.minutes.from_now }

    trait :password_reset do
      token_type { :password_reset }
    end

    trait :phone do
      token_type { :phone }
    end
  end
end
