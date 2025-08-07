require 'rails_helper'

RSpec.describe ClaimDriver, type: :model do
  include_examples "model_shared_spec", :claim_driver, [
    {
      name: [ { presence: true } ],
      phone: [ { presence: true } ],
      age: [ { presence: true }, { numericality: { greater_than: 16, less_than: 100 } } ],
      license_number: [ { presence: true } ],
      license_issue_date: [ { presence: true } ],
      license_expiry_date: [ { presence: true } ]
    },
    {
      claim: [ { belong_to: :claim } ]
    }
  ]

  describe 'validations' do
    let(:claim_driver) { build(:claim_driver) }

    describe '#license_expiry_after_issue' do
      it 'is invalid when license expiry is before issue date' do
        claim_driver.license_issue_date = 1.year.from_now
        claim_driver.license_expiry_date = Date.current
        expect(claim_driver).not_to be_valid
        expect(claim_driver.errors[:license_expiry_date]).to include('must be after issue date')
      end

      it 'is valid when license expiry is after issue date' do
        claim_driver.license_issue_date = 1.year.ago
        claim_driver.license_expiry_date = 1.year.from_now
        expect(claim_driver).to be_valid
      end
    end

    describe '#license_not_expired' do
      it 'is invalid when license is expired' do
        claim_driver.license_expiry_date = 1.year.ago
        expect(claim_driver).not_to be_valid
        expect(claim_driver.errors[:license_expiry_date]).to include('license is expired')
      end

      it 'is valid when license is not expired' do
        claim_driver.license_expiry_date = 1.year.from_now
        expect(claim_driver).to be_valid
      end
    end

    describe '#driver_age_valid_for_license' do
      it 'is invalid when driver was too young when license was issued' do
        claim_driver.age = 20
        claim_driver.license_issue_date = 10.years.ago
        expect(claim_driver).not_to be_valid
        expect(claim_driver.errors[:age]).to include('driver was too young when license was issued')
      end

      it 'is valid when driver was old enough when license was issued' do
        claim_driver.age = 30
        claim_driver.license_issue_date = 10.years.ago
        expect(claim_driver).to be_valid
      end
    end
  end

  describe 'scopes' do
    describe '.with_valid_license' do
      it 'returns only drivers with valid licenses' do
        puts "Before delete_all: #{ClaimDriver.count}"
        ClaimDriver.delete_all
        puts "After delete_all: #{ClaimDriver.count}"

        expired_driver = build(:claim_driver, :with_expired_license)
        expired_driver.save(validate: false)
        puts "After expired driver: #{ClaimDriver.count}"

        create(:claim_driver, license_expiry_date: 1.year.from_now, claim: create(:claim, without_driver: true))
        create(:claim_driver, city: 'Addis Ababa', license_expiry_date: 1.year.from_now, claim: create(:claim, without_driver: true))
        create(:claim_driver, city: 'Bahir Dar', license_expiry_date: 1.year.from_now, claim: create(:claim, without_driver: true))

        puts "Total drivers: #{ClaimDriver.count}"
        puts "Valid license drivers: #{ClaimDriver.with_valid_license.count}"
        ClaimDriver.all.each_with_index do |driver, i|
          puts "Driver #{i+1}: license_expiry_date=#{driver.license_expiry_date}, valid=#{driver.license_expiry_date > Date.current}"
        end

        expect(ClaimDriver.with_valid_license.count).to eq(3)
      end
    end

    describe '.by_city' do
      it 'returns drivers from specified city' do
        ClaimDriver.delete_all

        create(:claim_driver, city: 'Addis Ababa')
        create(:claim_driver, city: 'Bahir Dar')

        expect(ClaimDriver.by_city('Addis Ababa').count).to eq(1)
      end
    end
  end

  describe 'methods' do
    let(:claim_driver) { create(:claim_driver) }

    describe '#full_address' do
      it 'returns the full address as a string' do
        expect(claim_driver.full_address).to include(claim_driver.city)
        expect(claim_driver.full_address).to include(claim_driver.kebele)
      end
    end

    describe '#license_valid?' do
      it 'returns true when license is not expired' do
        claim_driver.license_expiry_date = 1.year.from_now
        expect(claim_driver.license_valid?).to be true
      end

      it 'returns false when license is expired' do
        claim_driver.license_expiry_date = 1.year.ago
        expect(claim_driver.license_valid?).to be false
      end
    end
  end
end
