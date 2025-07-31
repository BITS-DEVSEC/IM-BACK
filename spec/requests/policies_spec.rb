require 'rails_helper'

RSpec.describe "/policies", type: :request do
  let(:user) { create(:user) }
  let!(:insured_entity) { create(:insured_entity) }
  let!(:coverage_type) { create(:coverage_type) }

  let(:valid_attributes) do
    {
      policy_number: "POLICY-#{SecureRandom.hex(5)}",
      start_date: Date.today,
      end_date: Date.today + 1.year,
      premium_amount: 500.00,
      status: 'active',
      user_id: user.id,
      insured_entity_id: insured_entity.id,
      coverage_type_id: coverage_type.id
    }
  end

  let(:invalid_attributes) do
    {
      policy_number: nil,
      start_date: 'invalid-date',
      end_date: Date.today - 1.year,
      premium_amount: -100,
      status: 'invalid'
    }
  end

  let(:new_attributes) do
    {
      premium_amount: 600.00,
      status: 'pending'
    }
  end

  include_examples 'request_shared_spec', 'policies', 12
end
