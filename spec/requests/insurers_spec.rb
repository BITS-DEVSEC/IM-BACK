require 'rails_helper'

RSpec.describe InsurersController, type: :request do
  let(:valid_attributes) do
    {
      name: Faker::Company.unique.name,
      description: Faker::Company.catch_phrase,
      contact_email: Faker::Internet.email,
      contact_phone: Faker::PhoneNumber.phone_number,
      api_endpoint: Faker::Internet.url,
      api_key: Faker::Alphanumeric.alphanumeric(number: 32)
    }
  end

  let(:invalid_attributes) do
    {
      name: nil,
      description: Faker::Company.catch_phrase,
      contact_email: 'invalid-email',
      contact_phone: nil
    }
  end

  let(:new_attributes) do
    {
      name: "Updated Insurance Company",
      description: "Updated company description",
      contact_email: Faker::Internet.email,
      contact_phone: Faker::PhoneNumber.phone_number
    }
  end

  include_examples 'request_shared_spec', 'insurers', 8

  describe 'PUT /insurers/:id with logo' do
    let(:auth_user) { create(:user, :with_insurer) }
    let(:insurer) { auth_user.insurer }
    let(:token) { auth_user.generate_access_token }
    let(:headers) { { 'Authorization' => "Bearer #{token}" } }
    let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/sample_image.jpg'), 'image/jpeg') }

    it 'attaches a logo when provided' do
      params = {
        id: insurer.to_param,
        payload: valid_attributes.merge(logo: file)
      }

      put insurer_url(insurer), headers: headers, params: params

      expect(response).to have_http_status(:ok)
      result = JSON(response.body)
      expect(result['success']).to be_truthy
    end
  end
end
