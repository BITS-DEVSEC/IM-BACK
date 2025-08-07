require 'rails_helper'

RSpec.describe ClaimTimeline, type: :model do
  include_examples "model_shared_spec", :claim_timeline, [
    {
      event_type: [ { presence: true }, { inclusion: { in: ClaimTimeline::VALID_EVENT_TYPES } } ],
      occurred_at: [ { presence: true } ]
    },
    {
      claim: [ { belong_to: :claim } ]
    }
  ]

  describe 'scopes' do
    let(:claim) { create(:claim) }

    before do
      claim
      ClaimTimeline.delete_all

      create(:claim_timeline, :created_event, claim: claim)
      create(:claim_timeline, :submitted_event, claim: claim)
      create(:claim_timeline, :document_event, claim: claim)
      create(:claim_timeline, :approved_event, claim: claim)
    end

    describe '.recent' do
      it 'orders by occurred_at desc' do
        timelines = ClaimTimeline.recent
        expect(timelines.first.occurred_at).to be >= timelines.last.occurred_at
      end
    end

    describe '.by_event_type' do
      it 'filters by event type' do
        expect(ClaimTimeline.by_event_type('created').count).to eq(1)
      end
    end

    describe '.status_changes' do
      it 'returns only status change events' do
        expect(ClaimTimeline.status_changes.count).to eq(2)
      end
    end

    describe '.document_events' do
      it 'returns only document events' do
        expect(ClaimTimeline.document_events.count).to eq(1)
      end
    end
  end

  describe '.create_event' do
    let(:claim) { create(:claim) }
    let(:user) { create(:user) }

    it 'creates a timeline event with provided parameters' do
      timeline = ClaimTimeline.create_event(
        claim,
        'submitted',
        user,
        description: 'Custom description',
        metadata: { test: 'value' }
      )

      expect(timeline.claim).to eq(claim)
      expect(timeline.user).to eq(user)
      expect(timeline.event_type).to eq('submitted')
      expect(timeline.description).to eq('Custom description')
      expect(timeline.metadata['test']).to eq('value')
    end

    it 'uses default description when none provided' do
      timeline = ClaimTimeline.create_event(claim, 'submitted', user)
      expect(timeline.description).to include(claim.claim_number)
      expect(timeline.description).to include('submitted')
    end
  end

  describe '.default_description_for' do
    let(:claim) { create(:claim) }

    it 'returns appropriate description for each event type' do
      expect(ClaimTimeline.default_description_for('created', claim))
        .to include('created')
      expect(ClaimTimeline.default_description_for('submitted', claim))
        .to include('submitted')
      expect(ClaimTimeline.default_description_for('approved', claim))
        .to include('approved')
    end
  end

  describe 'instance methods' do
    let(:timeline) { create(:claim_timeline) }

    describe '#formatted_occurred_at' do
      it 'returns formatted date string' do
        timeline.occurred_at = Time.zone.parse('2025-01-15 14:30:00')
        expect(timeline.formatted_occurred_at).to include('January 15, 2025')
        expect(timeline.formatted_occurred_at).to include('02:30 PM')
      end
    end

    describe '#user_name' do
      context 'when user has full_name' do
        it 'returns full name' do
          user = create(:user)
          create(:customer, user: user, first_name: 'John', middle_name: "Little", last_name: 'Doe')
          timeline.user = user
          expect(timeline.user_name).to eq('John Little Doe')
        end
      end

      context 'when user has no full_name but has email' do
        it 'returns email' do
          user = create(:user)
          timeline.user = user
          expect(timeline.user_name).to eq(user.email)
        end
      end

      context 'when no user' do
        it 'returns System' do
          timeline.user = nil
          expect(timeline.user_name).to eq('System')
        end
      end
    end
  end
end
