FactoryBot.define do
  factory :task do
    title { Faker::Lorem.sentence(word_count: 4) }
    description { [ nil, Faker::Lorem.paragraph ].sample }
    due_date { [ nil, Faker::Date.forward(days: 30) ].sample }
    is_done { false }

    trait :done do
      is_done { true }
    end
  end
end
