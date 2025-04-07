FactoryBot.define do
  factory :vehicle do
    plate_number { "MyString" }
    chassis_number { "MyString" }
    engine_number { "MyString" }
    year_of_manufacture { 1 }
    make { "MyString" }
    model { "MyString" }
    estimated_value { "9.99" }
  end
end
