FactoryBot.define do
  factory :permission do
    sequence(:name) { |n| "permission_#{n}" }
    sequence(:resource) { |n| "resource_#{n}" }
    sequence(:action) { |n| "action_#{n}" }
  end
end
