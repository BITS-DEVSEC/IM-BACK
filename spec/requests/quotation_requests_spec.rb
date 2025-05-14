require 'rails_helper'

RSpec.describe "QuotationRequests", type: :request do
  let(:auth_user) { create(:user) }
  let(:insurance_type) { create(:insurance_type) }
  let(:coverage_type) { create(:coverage_type) }

  let(:valid_attributes) do
    {
      user_id: auth_user.id,
      insurance_type_id: insurance_type.id,
      coverage_type_id: coverage_type.id,
      status: "draft",
      form_data: {
        "insurance_type" => "Motor Insurance",
        "coverage_type" => "Comprehensive"
      },
      vehicle_attributes: {
        plate_number: "ABC1234",
        chassis_number: "XYZ123456789",
        engine_number: "ENG123456",
        make: "Toyota",
        model: "Corolla",
        year_of_manufacture: 2020,
        estimated_value: 150000
      }
    }
  end

  let(:new_attributes) do
    {
      form_data: {
        "insurance_type" => "Updated Insurance",
        "coverage_type" => "Updated Coverage"
      }
    }
  end

  let(:invalid_attributes) do
    {
      user_id: nil,
      insurance_type_id: nil,
      coverage_type_id: nil,
      form_data: {}
    }
  end

  include_examples 'request_shared_spec', 'quotation_requests', 9

  describe 'POST /create' do
    it 'creates a new QuotationRequest with vehicle' do
      expect do
        post(quotation_requests_url, headers: { 'Authorization' => "Bearer #{auth_user.generate_access_token}" }, params: { payload: valid_attributes }, as: :json)
      end.to change(QuotationRequest, :count).by(1)
        .and change(Vehicle, :count).by(1)

      expect(response).to have_http_status(:created)
      result = JSON(response.body)
      expect(result['success']).to be_truthy
      expect(result['data']['vehicle']['plate_number']).to eq("ABC1234")
    end

    it 'renders a JSON response with errors for invalid attributes' do
      post(quotation_requests_url, headers: { 'Authorization' => "Bearer #{auth_user.generate_access_token}" }, params: { payload: invalid_attributes }, as: :json)

      expect(response).to have_http_status(:unprocessable_entity)
      result = JSON(response.body)
      expect(result['success']).to be_falsey
      expect(result['error']).not_to be_blank
    end
  end

  describe 'PUT /update' do
    context 'with valid params' do
      it 'updates the requested QuotationRequest' do
        obj = create(:quotation_request, user: auth_user, insurance_type: insurance_type, coverage_type: coverage_type)
        params = { id: obj.to_param, payload: new_attributes }
        put(quotation_request_url(obj), headers: { 'Authorization' => "Bearer #{auth_user.generate_access_token}" }, params: params, as: :json)

        obj.reload
        expect(response).to have_http_status(:ok)
        expect(obj.form_data["insurance_type"]).to eq "Updated Insurance"

        result = JSON(response.body)
        expect(result['success']).to be_truthy
      end
    end

    context 'with invalid params' do
      it 'renders a JSON response with errors for the object' do
        obj = create(:quotation_request, user: auth_user, insurance_type: insurance_type, coverage_type: coverage_type)
        put(quotation_request_url(obj), headers: { 'Authorization' => "Bearer #{auth_user.generate_access_token}" }, params: { id: obj.to_param, payload: invalid_attributes }, as: :json)

        expect(response).to have_http_status(:unprocessable_entity)
        result = JSON(response.body)
        expect(result['success']).to be_falsey
      end
    end
  end
end
