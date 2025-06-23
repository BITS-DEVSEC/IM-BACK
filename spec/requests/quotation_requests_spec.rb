require 'rails_helper'

RSpec.describe QuotationRequestsController, type: :request do
  let(:coverage_type) { create(:coverage_type) }
  let(:insurance_product) { create(:insurance_product) }
  let(:entity_type) { EntityType.find_or_create_by(name: 'Vehicle') }

  let(:valid_attributes) do
    {
      entity_type: 'Vehicle',
      entity_data: {
        make: 'Toyota',
        model: 'Camry',
        plate_number: 'ET312345',
        year_of_manufacture: 2020,
        chassis_number: Faker::Vehicle.vin,
        engine_number: Faker::Alphanumeric.alphanumeric(number: 10),
        estimated_value: 500000,
        vehicle_type: 'Sedan',
        usage_type: 'Private',
        additional_fields: {
          color: 'Blue',
          fuel_type: 'Gasoline'
        }
      },
      coverage_type_id: coverage_type.id,
      insurance_product_id: insurance_product.id,
      form_data: {
        additional_notes: 'Test quotation request'
      }
    }
  end

  let(:invalid_attributes) do
    {
      entity_type: 'Vehicle',
      entity_data: {
        make: '',
        model: '',
        plate_number: '',
        year_of_manufacture: nil,
        estimated_value: nil,
        vehicle_type: '',
        usage_type: ''
      },
      coverage_type_id: nil,
      insurance_product_id: nil
    }
  end

  let(:new_attributes) do
    {
      status: 'approved'
    }
  end

  include_examples 'request_shared_spec', 'quotation_requests', 10, [ :create, :update ]

  describe 'POST /quotation_requests' do
    let(:auth_user) { create(:user, :with_customer) }
    let(:token) { auth_user.generate_access_token }
    let(:headers) { { 'Authorization' => "Bearer #{token}" } }

    before do
      EntityType.find_or_create_by(name: 'Vehicle')

      role = create(:role, name: 'customer')
      auth_user.roles << role
      permission = create(:permission, action: 'create', resource: 'quotation_requests')
      role.permissions << permission
    end

    context 'with valid params' do
      it 'creates a new quotation request' do
        expect {
          post quotation_requests_url, headers: headers, params: valid_attributes, as: :json
        }.to change(QuotationRequest, :count).by(1)
         .and change(Vehicle, :count).by(1)
         .and change(InsuredEntity, :count).by(1)

        expect(response).to have_http_status(:created)
        result = JSON(response.body)
        expect(result['success']).to be_truthy
        expect(result['data']['status']).to eq('pending')
      end

      it 'creates quotation request with file attachments' do
        file = fixture_file_upload(Rails.root.join('spec/fixtures/files/sample_image.jpg'), 'image/jpeg')
        params = valid_attributes.deep_merge(
          entity_data: {
            files: { front_view_photo: file }
          }
        )
        post quotation_requests_url, headers: headers, params: params

        expect(response).to have_http_status(:created)
        result = JSON(response.body)
        expect(result['success']).to be_truthy

        vehicle = Vehicle.last
        expect(vehicle.front_view_photo).to be_attached
      end

      it 'creates quotation request with residence address' do
        residence_params = {
          region: 'Addis Ababa',
          subcity: 'Bole',
          woreda: '03',
          zone: 'Megenagna',
          house_number: '123'
        }

        params = valid_attributes.merge(residence_address: residence_params)

        expect {
          post quotation_requests_url, headers: headers, params: params, as: :json
        }.to change(ResidenceAddress, :count).by(1)

        expect(response).to have_http_status(:created)

        customer = auth_user.customer.reload
        expect(customer.current_address.region).to eq('Addis Ababa')
        expect(customer.current_address.subcity).to eq('Bole')
      end

      it 'updates existing current address when new residence address provided' do
        create(:residence_address, :current, customer: auth_user.customer)

        residence_params = {
          region: 'Oromia',
          subcity: 'Adama',
          woreda: '01',
          zone: 'Center'
        }

        params = valid_attributes.merge(residence_address: residence_params)

        expect {
          post quotation_requests_url, headers: headers, params: params, as: :json
        }.to change(ResidenceAddress, :count).by(1)

        expect(response).to have_http_status(:created)

        customer = auth_user.customer.reload
        expect(customer.current_address.region).to eq('Oromia')
        expect(customer.residence_addresses.where(is_current: false).count).to eq(1)
      end
    end

    context 'with invalid params' do
      it 'renders errors for invalid entity data' do
        post quotation_requests_url, headers: headers, params: invalid_attributes, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        result = JSON(response.body)
        expect(result['success']).to be_falsey
        expect(result['errors']).to be_present
      end

      it 'handles unknown entity type' do
        params = valid_attributes.merge(entity_type: 'UnknownEntity')

        post quotation_requests_url, headers: headers, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        result = JSON(response.body)
        expect(result['success']).to be_falsey
        expect(result['error']).to include('Unknown entity type')
      end

      it 'handles user without customer profile' do
        user_without_customer = create(:user)
        token_without_customer = user_without_customer.generate_access_token
        headers_without_customer = { 'Authorization' => "Bearer #{token_without_customer}" }

        post quotation_requests_url, headers: headers_without_customer, params: valid_attributes, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        result = JSON(response.body)
        expect(result['success']).to be_falsey
        expect(result['errors']).to include('User must have a customer profile')
      end

      it 'handles invalid residence address data' do
        residence_params = {
          region: '',
          subcity: '',
          woreda: ''
        }

        params = valid_attributes.merge(residence_address: residence_params)

        post quotation_requests_url, headers: headers, params: params, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        result = JSON(response.body)
        expect(result['success']).to be_falsey
      end
    end
  end
end
