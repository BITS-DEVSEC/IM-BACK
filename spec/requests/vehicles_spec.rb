require 'rails_helper'

RSpec.describe "Vehicles API", type: :request do
  include ActionDispatch::TestProcess::FixtureFile

  let(:valid_attributes) do
    {
      make: "Toyota",
      model: "Corolla",
      year_of_manufacture: 2022,
      estimated_value: 1500000.00,
      plate_number: "ABC123",
      chassis_number: "CHASSIS123456",
      engine_number: "ENGINE123456",
      front_view_photo: fixture_file_upload(Rails.root.join("spec/fixtures/files/sample_image.jpg"), "image/jpeg")
    }
  end

  let(:invalid_attributes) do
    {
      make: nil,
      model: "Corolla",
      year_of_manufacture: 2022
    }
  end

  let(:new_attributes) do
    {
      model: "Camry"
    }
  end

  it_behaves_like "request_shared_spec", "vehicles", 15

  describe 'POST /vehicles with multipart for file upload' do
    let(:auth_user) { create(:user) }
    let(:token) { auth_user.generate_access_token }
    let(:headers) { { 'Authorization' => "Bearer #{token}" } }
    it 'creates a new vehicle with image' do
      expect {
        post vehicles_url, headers:, params: { payload: valid_attributes }, as: :multipart
        puts JSON.parse(response.body)
      }.to change(Vehicle, :count).by(1)

      expect(response).to have_http_status(:created)
      result = JSON.parse(response.body)

      expect(result["success"]).to be_truthy
      expect(result["data"]["plate_number"]).to eq("ABC123")
      expect(result["data"]["front_view_photo_url"]).to be_a(String)
      expect(result["data"]["front_view_photo_url"]).to match(%r{http://|https://})
      expect(Vehicle.last.front_view_photo).to be_attached
    end
  end
end
