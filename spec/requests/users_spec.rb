require 'rails_helper'

RSpec.describe "Users", type: :request do
  let(:valid_attributes) do
    {
      email: Faker::Internet.unique.email,
      password: "password123",
      password_confirmation: "password123",
      phone_number: Faker::PhoneNumber.cell_phone,
      fin: Faker::Alphanumeric.alphanumeric(number: 10).upcase
    }
  end

  let(:invalid_attributes) do
    {
      email: "",
      password: "123",
      password_confirmation: "456"
    }
  end

  let(:new_attributes) do
    {
      email: Faker::Internet.unique.email,
      password: "new_password123",
      password_confirmation: "new_password123",
      phone_number: Faker::PhoneNumber.cell_phone,
      fin: Faker::Alphanumeric.alphanumeric(number: 10).upcase
    }
  end


  include_examples "request_shared_spec", "users", 11
end
