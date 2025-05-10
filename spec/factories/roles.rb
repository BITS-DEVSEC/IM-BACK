FactoryBot.define do
  factory :role do
    sequence(:name) { |n| "role_#{n}" }
  end

  trait :admin do
    name { 'admin' }
  end

  trait :agent do
    name { 'agent' }
  end

  trait :customer do
    name { 'customer' }
  end
end
