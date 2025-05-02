FactoryBot.define do
  factory :refresh_token do
    association :user
    refresh_token { SecureRandom.uuid }
    expires_at { 7.days.from_now }
    device { 'web' }
    ip_address { Faker::Internet.ip_v4_address }
    user_agent { 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)' }

    trait :expired do
      expires_at { 1.day.ago }
    end
  end
end
