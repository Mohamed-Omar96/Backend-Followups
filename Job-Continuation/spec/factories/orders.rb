FactoryBot.define do
  factory :order do
    customer
    status { "pending" }
    amount { Faker::Commerce.price(range: 10.0..500.0, as_string: false) }
    processed_at { nil }

    trait :processed do
      status { "processed" }
      processed_at { Time.current }
    end

    trait :failed do
      status { "failed" }
    end
  end
end
