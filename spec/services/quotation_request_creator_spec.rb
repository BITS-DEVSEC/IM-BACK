require 'rails_helper'

RSpec.describe QuotationRequestCreator, type: :service do
  let(:user) { create(:user, :with_customer) }
  let(:coverage_type) { create(:coverage_type) }
  let(:insurance_product) { create(:insurance_product) }
  let!(:entity_type) { create(:entity_type, name: 'Vehicle') }

  let(:entity_params) do
    {
      make: 'Toyota',
      model: 'Camry',
      year_of_manufacture: 2020,
      plate_number: 'ABC123',
      chassis_number: Faker::Vehicle.vin,
      engine_number: Faker::Alphanumeric.alphanumeric(number: 10),
      estimated_value: 500_000,
      vehicle_type: 'Sedan',
      usage_type: 'Private',
      additional_fields: {
        color: 'Blue',
        fuel_type: 'Gasoline'
      }
    }
  end

  let(:quotation_params) do
    {
      coverage_type_id: coverage_type.id,
      insurance_product_id: insurance_product.id,
      form_data: { additional_notes: 'Test quotation' }
    }
  end

  describe '#call' do
    context 'with valid parameters' do
      let(:service) do
        described_class.new(
          user: user,
          entity_class: Vehicle,
          entity_params: entity_params,
          file_params: nil,
          quotation_params: quotation_params
        )
      end

      it 'creates a quotation request successfully' do
        expect {
          result = service.call
          expect(result).to be_a(QuotationRequest)
          expect(result).to be_persisted
        }.to change(QuotationRequest, :count).by(1)
         .and change(Vehicle, :count).by(1)
         .and change(InsuredEntity, :count).by(1)
      end

      it 'sets correct attributes on quotation request' do
        result = service.call

        expect(result.user).to eq(user)
        expect(result.status).to eq('pending')
        expect(result.coverage_type).to eq(coverage_type)
        expect(result.insurance_product).to eq(insurance_product)
        expect(result.form_data).to eq({ 'additional_notes' => 'Test quotation' })
      end

      it 'creates associated vehicle with correct attributes' do
        result = service.call
        vehicle = result.insured_entity.entity

        expect(vehicle).to be_a(Vehicle)
        expect(vehicle.make).to eq('Toyota')
        expect(vehicle.model).to eq('Camry')
        expect(vehicle.year_of_manufacture).to eq(2020)
      end

      it 'creates insured entity with correct associations' do
        result = service.call
        insured_entity = result.insured_entity

        expect(insured_entity.user).to eq(user)
        expect(insured_entity.insurance_type).to eq(coverage_type.insurance_type)
        expect(insured_entity.entity_type.name).to eq('Vehicle')
      end
    end

    context 'with file attachments' do
      let(:file) { fixture_file_upload(Rails.root.join('spec/fixtures/files/sample_image.jpg'), 'image/jpeg') }
      let(:file_params) { { libre_photo: file } }

      let(:service) do
        described_class.new(
          user: user,
          entity_class: Vehicle,
          entity_params: entity_params,
          file_params: file_params,
          quotation_params: quotation_params
        )
      end

      it 'attaches files to the entity' do
        result = service.call
        vehicle = result.insured_entity.entity

        expect(vehicle.libre_photo).to be_attached
      end
    end

    context 'with residence address parameters' do
      let(:residence_address_params) do
        {
          region: 'Addis Ababa',
          subcity: 'Bole',
          woreda: '03',
          zone: 'Megenagna'
        }
      end

      let(:service) do
        described_class.new(
          user: user,
          entity_class: Vehicle,
          entity_params: entity_params,
          file_params: nil,
          quotation_params: quotation_params,
          residence_address_params: residence_address_params
        )
      end

      it 'creates a new residence address' do
        expect {
          service.call
        }.to change(ResidenceAddress, :count).by(1)

        customer = user.customer.reload
        expect(customer.current_address.region).to eq('Addis Ababa')
        expect(customer.current_address.subcity).to eq('Bole')
      end

      it 'updates existing current address' do
        create(:residence_address, :current, customer: user.customer)

        expect {
          service.call
        }.to change(ResidenceAddress, :count).by(1)

        customer = user.customer.reload
        expect(customer.current_address.region).to eq('Addis Ababa')
        expect(customer.residence_addresses.where(is_current: false).count).to eq(1)
      end
    end

    context 'with invalid parameters' do
      context 'when user has no customer profile' do
        let(:user_without_customer) { create(:user) }

        let(:service) do
          described_class.new(
            user: user_without_customer,
            entity_class: Vehicle,
            entity_params: entity_params,
            file_params: nil,
            quotation_params: quotation_params
          )
        end

        it 'returns nil and sets error' do
          result = service.call

          expect(result).to be_nil
          expect(service.errors).to include('User must have a customer profile')
        end
      end

      context 'when entity validation fails' do
        let(:invalid_entity_params) { entity_params.merge(make: '', model: '') }

        let(:service) do
          described_class.new(
            user: user,
            entity_class: Vehicle,
            entity_params: invalid_entity_params,
            file_params: nil,
            quotation_params: quotation_params
          )
        end

        it 'returns nil and sets errors' do
          result = service.call

          expect(result).to be_nil
          expect(service.errors).to include("Make can't be blank")
        end

        it 'does not create any records' do
          expect {
            service.call
          }.not_to(change { [ QuotationRequest.count, Vehicle.count, InsuredEntity.count ] })
        end
      end

      context 'when residence address validation fails' do
        let(:invalid_residence_params) do
          {
            region: '',
            subcity: '',
            woreda: ''
          }
        end

        let(:service) do
          described_class.new(
            user: user,
            entity_class: Vehicle,
            entity_params: entity_params,
            file_params: nil,
            quotation_params: quotation_params,
            residence_address_params: invalid_residence_params
          )
        end

        it 'returns nil and sets errors' do
          result = service.call

          expect(result).to be_nil
          expect(service.errors).to include("Region can't be blank")
        end
      end

      context 'when quotation request validation fails' do
        let(:invalid_quotation_params) do
          {
            coverage_type_id: nil,
            insurance_product_id: nil,
            form_data: {}
          }
        end

        let(:service) do
          described_class.new(
            user: user,
            entity_class: Vehicle,
            entity_params: entity_params,
            file_params: nil,
            quotation_params: invalid_quotation_params
          )
        end

        it 'returns nil and sets errors' do
          result = service.call

          expect(result).to be_nil
          expect(service.errors).not_to be_empty
        end
      end
    end

    context 'transaction rollback' do
      let(:service) do
        described_class.new(
          user: user,
          entity_class: Vehicle,
          entity_params: entity_params,
          file_params: nil,
          quotation_params: quotation_params
        )
      end

      it 'rolls back all changes when an error occurs' do
        allow_any_instance_of(QuotationRequest).to receive(:save).and_return(false)
        allow_any_instance_of(QuotationRequest).to receive(:errors).and_return(
          double(full_messages: [ 'Some validation error' ])
        )

        expect {
          service.call
        }.not_to(change { [ Vehicle.count, InsuredEntity.count, QuotationRequest.count ] })

        expect(service.errors).to include('Some validation error')
      end
    end
  end

  describe '#errors' do
    let(:service) do
      described_class.new(
        user: create(:user), # User without customer
        entity_class: Vehicle,
        entity_params: entity_params,
        file_params: nil,
        quotation_params: quotation_params
      )
    end

    it 'returns empty array initially' do
      expect(service.errors).to eq([])
    end

    it 'accumulates errors during execution' do
      service.call
      expect(service.errors).not_to be_empty
    end
  end
end
