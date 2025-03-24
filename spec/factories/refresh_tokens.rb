FactoryBot.define do
  factory :refresh_token do
    association :user
    refresh_token { SecureRandom.uuid }
    expires_at { 7.days.from_now }
    ip_address { "127.0.0.1" }
  end
end
