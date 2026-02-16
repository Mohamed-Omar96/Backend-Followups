FactoryBot.define do
  factory :email_campaign do
    name { Faker::Marketing.buzzwords.titleize }
    subject { Faker::Company.catch_phrase }
    status { "pending" }
    sent_count { 0 }
    total_recipients { 500 }

    trait :in_progress do
      status { "in_progress" }
      sent_count { 100 }
    end

    trait :completed do
      status { "completed" }
      sent_count { total_recipients }
    end
  end
end
