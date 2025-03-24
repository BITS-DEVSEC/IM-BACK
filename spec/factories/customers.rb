FactoryBot.define do
  factory :customer do
    user { nil }
    first_name { "MyString" }
    middle_name { "MyString" }
    last_name { "MyString" }
    birthdate { "2025-03-17" }
    gender { "MyString" }
    region { "MyString" }
    subcity { "MyString" }
    woreda { "MyString" }
  end
end
