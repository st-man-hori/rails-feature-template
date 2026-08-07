# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Faker is a development/test-only dependency (see Gemfile), so this is meant to be run locally, not in production --
# the same assumption the Laravel version's DatabaseSeeder makes with fakerphp/faker.

5.times do
  Task.create!(
    title: Faker::Lorem.sentence(word_count: 4),
    description: Faker::Lorem.paragraph,
    due_date: Faker::Date.forward(days: 30),
    is_done: [ true, false ].sample,
  )
end
