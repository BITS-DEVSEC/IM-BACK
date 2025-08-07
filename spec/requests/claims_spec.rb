require 'rails_helper'

RSpec.describe ClaimsController, type: :request do
  let(:auth_user) { create(:user, :with_policies) }
  let(:policy) { auth_user.policies.first }
  let(:token) { auth_user.generate_access_token }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  let(:valid_attributes) do
    {
      payload: {
        description: 'Vehicle collision on main road',
        claimed_amount: 15000.0,
        incident_date: Date.current,
        incident_location: 'Bole Road, Addis Ababa',
        incident_time: '14:30',
        incident_type: 'collision',
        damage_description: 'Front bumper damage and headlight broken',
        vehicle_speed: '40 km/h',
        distance_from_roadside: '2 meters',
        horn_sounded: true,
        inside_vehicle: true,
        police_notified: true,
        third_party_involved: true,
        additional_details: 'Weather was clear, good visibility',
        claim_driver_attributes: {
          name: 'John Doe',
          phone: '0911234567',
          license_number: 'AA123456',
          age: 35,
          occupation: 'Engineer',
          address: 'Main Street 123',
          city: 'Addis Ababa',
          subcity: 'Bole',
          kebele: 'Kebele 03',
          house_number: '123',
          license_issuing_region: 'Addis Ababa',
          license_issue_date: '2022-01-15',
          license_expiry_date: '2027-01-15',
          license_grade: 'Grade 3'
        }
      },
      policy_id: policy.id
    }
  end

  let(:invalid_attributes) do
    {
      payload: {
        description: '',
        claimed_amount: -100,
        incident_date: Date.current + 1.day
      },
      policy_id: policy.id
    }
  end

  before do
    role = create(:role, name: 'customer')
    auth_user.roles << role

    # Create basic permissions
    %w[read create update delete].each do |action|
      permission = create(:permission, action: action, resource: 'claims')
      role.permissions << permission
    end
  end

  describe 'GET /claims' do
    before do
      create_list(:claim, 3, policy: policy)
      create(:claim, :pending, policy: policy)
      create(:claim, :approved, policy: policy)
    end

    it 'returns all user claims' do
      get '/claims', headers: headers

      expect(response).to have_http_status(:ok)
      result = JSON.parse(response.body)
      expect(result['success']).to be_truthy
      expect(result['data'].length).to eq(5)
    end

    it 'filters claims by status' do
      get '/claims', params: { filter: { status: 'pending' } }, headers: headers

      expect(response).to have_http_status(:ok)
      result = JSON.parse(response.body)
      expect(result['data'].length).to eq(1)
      expect(result['data'].first['status']).to eq('pending')
    end

    it 'filters claims by date range' do
      # Create a policy with start date 60 days ago to allow for test incident dates
      date_policy = create(:policy, user: auth_user, start_date: 60.days.ago, end_date: 30.days.from_now)
      recent_claim = create(:claim, policy: date_policy, incident_date: Date.current - 2.days)
      old_claim = create(:claim, policy: date_policy, incident_date: Date.current - 30.days)

      get '/claims', params: {
        filter: {
          from_date: (Date.current - 7.days).to_s,
          to_date: Date.current.to_s
        }
      }, headers: headers

      expect(response).to have_http_status(:ok)
      result = JSON.parse(response.body)
      claim_ids = result['data'].map { |c| c['id'] }
      expect(claim_ids).to include(recent_claim.id)
      expect(claim_ids).not_to include(old_claim.id)
    end
  end

  describe 'GET /claims/:id' do
    let(:claim) { create(:claim, :pending, policy: policy) }

    it 'returns the claim with full details' do
      get "/claims/#{claim.id}", headers: headers

      expect(response).to have_http_status(:ok)
      result = JSON.parse(response.body)
      expect(result['success']).to be_truthy
      expect(result['data']['id']).to eq(claim.id)
      expect(result['data']['claim_driver']).to be_present
      expect(result['data']['claim_timelines']).to be_present
    end

    it 'includes policy information' do
      get "/claims/#{claim.id}", headers: headers

      result = JSON.parse(response.body)
      expect(result['data']['policy']).to be_present
      expect(result['data']['policy']['policy_number']).to eq(policy.policy_number)
    end
  end

  describe 'POST /policies/:policy_id/claims' do
    it 'creates a new claim' do
      expect {
        post "/policies/#{policy.id}/claims",
             params: valid_attributes,
             headers: headers,
             as: :json
      }.to change(Claim, :count).by(1)

      expect(response).to have_http_status(:created)
      result = JSON.parse(response.body)
      expect(result['success']).to be_truthy
      expect(result['data']['status']).to eq('draft')
      expect(result['data']['claim_number']).to be_present
    end

    it 'generates a unique claim number' do
      post "/policies/#{policy.id}/claims",
           params: valid_attributes,
           headers: headers,
           as: :json

      result = JSON.parse(response.body)
      expect(result['data']['claim_number']).to match(/CL-\d{4}-[A-F0-9]{8}/)
    end

    it 'returns validation errors for invalid data' do
      post "/policies/#{policy.id}/claims",
           params: invalid_attributes,
           headers: headers,
           as: :json

      expect(response).to have_http_status(:unprocessable_entity)
      result = JSON.parse(response.body)
      expect(result['success']).to be_falsey
      expect(result['errors']).to be_present
    end

    it 'prevents creating claims for other users policies' do
      other_user = create(:user, :with_policies)
      other_policy = other_user.policies.first

      post "/policies/#{other_policy.id}/claims",
           params: valid_attributes.merge(policy_id: other_policy.id),
           headers: headers,
           as: :json

      expect(response).to have_http_status(:forbidden)
    end

    it 'creates a claim without driver attributes' do
      simple_attributes = {
        payload: {
          description: 'Vehicle collision on main road',
          claimed_amount: 15000.0,
          incident_date: Date.current,
          incident_location: 'Bole Road, Addis Ababa',
          incident_time: '14:30',
          incident_type: 'collision',
          damage_description: 'Front bumper damage'
        },
        policy_id: policy.id
      }

      expect {
        post "/policies/#{policy.id}/claims",
             params: simple_attributes,
             headers: headers,
             as: :json
      }.to change(Claim, :count).by(1)

      expect(response).to have_http_status(:created)
      result = JSON.parse(response.body)
      expect(result['success']).to be_truthy
      expect(result['data']['status']).to eq('draft')
    end
  end

  describe 'PATCH /claims/:id' do
    let(:claim) { create(:claim, :draft, policy: policy) }

    let(:update_attributes) do
      {
        payload: {
          description: 'Updated description',
          claimed_amount: 20000.0
        }
      }
    end

    it 'updates the claim' do
      patch "/claims/#{claim.id}",
            params: update_attributes,
            headers: headers,
            as: :json

      expect(response).to have_http_status(:ok)
      result = JSON.parse(response.body)
      expect(result['data']['description']).to eq('Updated description')
      expect(result['data']['claimed_amount']).to eq(20000.0)
    end

    it 'prevents updating claims that cannot be updated by user' do
      approved_claim = create(:claim, :approved, policy: policy)

      patch "/claims/#{approved_claim.id}",
            params: update_attributes,
            headers: headers,
            as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'PATCH /claims/:id/submit' do
    let(:claim) { create(:claim, :draft, policy: policy) }

    it 'submits a draft claim' do
      patch "/claims/#{claim.id}/submit", headers: headers, as: :json

      expect(response).to have_http_status(:ok)
      result = JSON.parse(response.body)
      expect(result['data']['status']).to eq('pending')
      expect(result['data']['submitted_at']).to be_present
    end

    it 'prevents submitting non-draft claims' do
      pending_claim = create(:claim, :pending, policy: policy)

      patch "/claims/#{pending_claim.id}/submit", headers: headers, as: :json

      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe 'PATCH /claims/:id/update_status' do
    let(:insurer_user) { create(:user, :with_insurer) }
    let(:insurer_token) { insurer_user.generate_access_token }
    let(:insurer_headers) { { 'Authorization' => "Bearer #{insurer_token}" } }
    let(:coverage_type) { create(:coverage_type) }
    let(:insurance_product) { create(:insurance_product, insurer: insurer_user.insurer, coverage_type: coverage_type) }
    let(:insurer_policy) { create(:policy, coverage_type: coverage_type) }
    let(:claim) { create(:claim, :pending, policy: insurer_policy) }

    before do
      role = create(:role, name: 'insurer')
      insurer_user.roles << role
      permission = create(:permission, action: 'update', resource: 'claims')
      role.permissions << permission
    end

    it 'allows insurers to update claim status' do
      patch "/claims/#{claim.id}/update_status",
            params: { status: 'approved', settlement_amount: 18000 },
            headers: insurer_headers,
            as: :json

      expect(response).to have_http_status(:ok)
      result = JSON.parse(response.body)
      expect(result['data']['status']).to eq('approved')
      expect(result['data']['settlement_amount']).to eq(18000.0)
    end

    it 'prevents regular users from updating status' do
      patch "/claims/#{claim.id}/update_status",
            params: { status: 'approved' },
            headers: headers,
            as: :json

      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'DELETE /claims/:id' do
    let(:claim) { create(:claim, :draft, policy: policy) }

    it 'allows deleting draft claims' do
      delete "/claims/#{claim.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(Claim.exists?(claim.id)).to be_falsey
    end

    it 'prevents deleting submitted claims' do
      submitted_claim = create(:claim, :pending, policy: policy)

      delete "/claims/#{submitted_claim.id}", headers: headers

      expect(response).to have_http_status(:forbidden)
    end
  end
end
