require 'rails_helper'

RSpec.describe Vehicle, type: :model do
  photo_attributes = %i[
    front_view_photo
    back_view_photo
    left_view_photo
    right_view_photo
    engine_photo
    chassis_number_photo
    libre_photo
  ]

  photo_validations = [
    { content_type: {
        allowed: [ 'image/jpeg', 'image/png' ],
        message: 'must be a JPEG or PNG'
      }
    },
    { size: {
        less_than: 5.megabytes,
        message: 'must be less than 5MB'
      }
    }
  ]

  attributes = [
    { plate_number: [ :presence, :uniqueness ] },
    { chassis_number: [ :presence, :uniqueness ] },
    { engine_number: [ :presence, :uniqueness ] },
    { year_of_manufacture: [ :presence, { numericality: { only_integer: true } } ] },
    { make: [ :presence ] },
    { model: [ :presence ] },
    { estimated_value: [ :presence, { numericality: { greater_than: 0 } } ] },
    { insured_entity: [ :have_one ] },
    { entity_categories: [ :have_many ] },
    { entity_attributes: [ :have_many ] },
    { vehicle_type: [ :presence ] },
    { usage_type: [ :presence ] }
  ] + photo_attributes.map { |photo| { photo => photo_validations } }
  include_examples "model_shared_spec", :vehicle, attributes

  describe 'validations' do
    subject { build(:vehicle) }

    it 'validates year_of_manufacture is not in the future' do
      subject.year_of_manufacture = Date.current.year + 1
      expect(subject).not_to be_valid
      expect(subject.errors[:year_of_manufacture]).to include('cannot be in the future')
    end

    it 'validates year_of_manufacture is not too old' do
      subject.year_of_manufacture = 1900
      expect(subject).not_to be_valid
      expect(subject.errors[:year_of_manufacture]).to include('is too old')
    end

    it 'validates estimated_value is greater than zero' do
      subject.estimated_value = 0
      expect(subject).not_to be_valid
      expect(subject.errors[:estimated_value]).to include('must be greater than 0')
    end

    it 'validates plate_number format' do
      subject.plate_number = 'INVALID-FORMAT'
      expect(subject).not_to be_valid
      expect(subject.errors[:plate_number]).to include('has invalid format')
    end
  end


  describe 'scopes' do
    before do
      @new = create(:vehicle, estimated_value: 50_000, created_at: Time.current)
      @toyota = create(:vehicle, make: 'Toyota', year_of_manufacture: 2024, estimated_value: 60_000, created_at: 1.day.ago)
      @honda = create(:vehicle, make: 'Honda', year_of_manufacture: 2023, estimated_value: 55_000, created_at: 2.days.ago)
      @ford = create(:vehicle, make: 'Ford', year_of_manufacture: 2023, estimated_value: 65_000, created_at: 3.days.ago)
      @old = create(:vehicle, year_of_manufacture: 2010, estimated_value: 20_000, created_at: 4.days.ago)
      @cheap = create(:vehicle, estimated_value: 10_000, created_at: 5.days.ago)
      @expensive = create(:vehicle, estimated_value: 100_000, created_at: 6.days.ago)
    end


    it 'filters by make' do
      expect(Vehicle.by_make('Toyota')).to include(@toyota)
      expect(Vehicle.by_make('Toyota')).not_to include(@honda, @ford)
    end

    it 'filters by model year range' do
      expect(Vehicle.by_year_range(2009, 2015)).to include(@old)
      expect(Vehicle.by_year_range(2009, 2014)).not_to include(@new)
    end

    it 'filters by value range' do
      expect(Vehicle.by_value_range(5_000, 50_000)).to include(@cheap)
      expect(Vehicle.by_value_range(5_000, 50_000)).not_to include(@expensive)
    end

    it 'orders by newest first' do
      expect(Vehicle.newest_first.first).to eq(@new)
      expect(Vehicle.newest_first.last).to eq(@expensive)
    end

    it 'orders by most valuable first' do
      expect(Vehicle.most_valuable_first.first).to eq(@expensive)
      expect(Vehicle.most_valuable_first.last).to eq(@cheap)
    end
  end

  describe 'instance methods' do
    let(:vehicle) { create(:vehicle, make: 'Toyota', model: 'Corolla', year_of_manufacture: 2020) }

    it 'returns full name with make, model and year' do
      expect(vehicle.full_name).to eq('Toyota Corolla (2020)')
    end

    it 'calculates age based on year of manufacture' do
      current_year = Date.current.year
      expected_age = current_year - 2020
      expect(vehicle.age).to eq(expected_age)
    end

    it 'determines if vehicle is new (less than 3 years old)' do
      allow(vehicle).to receive(:age).and_return(2)
      expect(vehicle.new?).to be_truthy

      allow(vehicle).to receive(:age).and_return(4)
      expect(vehicle.new?).to be_falsey
    end
  end
end
