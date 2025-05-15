require 'rails_helper'

RSpec.describe "QuotationRequests", type: :request do
  let(:auth_user) { create(:user) }
  let(:insurance_type) { create(:insurance_type) }
  let(:coverage_type) { create(:coverage_type) }

  let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/sample_image.jpg'), 'image/jpeg') }

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

  let(:invalid_attributes) do
    {
      user_id: nil,
      insurance_type_id: nil,
      coverage_type_id: nil,
      form_data: {}
    }
  end

  describe 'POST /create' do
    it 'creates a new QuotationRequest with vehicle and image' do
      expect {
        post(
          quotation_requests_url,
          headers: { 'Authorization' => "Bearer #{auth_user.generate_access_token}" },
          params: {
            payload: valid_attributes.to_json,
            'vehicle_attributes[front_view_photo]' => file
          },
          as: :multipart
        )
      }.to change(QuotationRequest, :count).by(1)
        .and change(Vehicle, :count).by(1)

      expect(response).to have_http_status(:created)
      body = JSON.parse(response.body)
      expect(body['success']).to be true
      expect(body['data']['vehicle']['plate_number']).to eq("ABC1234")
    end

    it 'fails to create with invalid attributes' do
      post(
        quotation_requests_url,
        headers: { 'Authorization' => "Bearer #{auth_user.generate_access_token}" },
        params: {
          payload: invalid_attributes.to_json
        },
        as: :multipart
      )

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body['success']).to be false
    end
  end

  describe 'PUT /update' do
    it 'updates an existing QuotationRequest' do
      request = create(:quotation_request, user: auth_user, insurance_type: insurance_type, coverage_type: coverage_type)
      update_data = {
        form_data: {
          "insurance_type" => "Updated Insurance",
          "coverage_type" => "Updated Coverage"
        }
      }

      put(
        quotation_request_url(request),
        headers: { 'Authorization' => "Bearer #{auth_user.generate_access_token}" },
        params: {
          id: request.id,
          payload: update_data.to_json
        },
        as: :multipart
      )

      expect(response).to have_http_status(:ok)
      request.reload
      expect(request.form_data["insurance_type"]).to eq("Updated Insurance")
    end

    it 'fails to update with invalid data' do
      request = create(:quotation_request, user: auth_user, insurance_type: insurance_type, coverage_type: coverage_type)

      put(
        quotation_request_url(request),
        headers: { 'Authorization' => "Bearer #{auth_user.generate_access_token}" },
        params: {
          id: request.id,
          payload: invalid_attributes.to_json
        },
        as: :multipart
      )

      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body['success']).to be false
    end
  end

  describe 'GET /index' do
    it 'returns a list of quotation requests' do
      create_list(:quotation_request, 3, user: auth_user, insurance_type: insurance_type, coverage_type: coverage_type)

      get(
        quotation_requests_url,
        headers: { 'Authorization' => "Bearer #{auth_user.generate_access_token}" }
      )

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['data'].length).to be >= 3
    end
  end

  describe 'GET /show' do
    it 'returns a single quotation request' do
      request = create(:quotation_request, user: auth_user, insurance_type: insurance_type, coverage_type: coverage_type)

      get(
        quotation_request_url(request),
        headers: { 'Authorization' => "Bearer #{auth_user.generate_access_token}" }
      )

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)
      expect(body['data']['id']).to eq(request.id)
    end
  end
end
