FactoryBot.define do
  factory :claim_timeline do
    association :claim
    association :user
    event_type { ClaimTimeline::VALID_EVENT_TYPES.sample }
    description { Faker::Lorem.sentence }
    occurred_at { Faker::Time.between(from: 1.month.ago, to: Time.current) }
    metadata { {} }

    trait :status_change do
      event_type { [ 'submitted', 'under_review', 'approved', 'rejected', 'paid' ].sample }
    end

    trait :document_event do
      event_type { [ 'document_uploaded', 'document_removed' ].sample }
      metadata { { document_type: [ 'police_report', 'photos', 'receipts' ].sample } }
    end

    trait :created_event do
      event_type { 'created' }
      occurred_at { 1.week.ago }
    end

    trait :submitted_event do
      event_type { 'submitted' }
      occurred_at { 5.days.ago }
    end

    trait :approved_event do
      event_type { 'approved' }
      occurred_at { 2.days.ago }
    end
  end
end
