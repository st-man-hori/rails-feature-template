source "https://rubygems.org"

gem "rails", "~> 8.1.3", ">= 8.1.3.1"
# Use mysql as the database for Active Record (development/production;
# tests use sqlite3 in-memory -- see the :test group below).
gem "mysql2", "~> 0.5"
# Use the Puma web server [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Speeds up boot time by caching expensive require/load-path work
gem "bootsnap", require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
# gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Request specs (Laravel: PHPUnit / Pest)
  gem "rspec-rails", "~> 8.0"
  # Model factories (Laravel: database/factories)
  gem "factory_bot_rails", "~> 6.4"
  # Fake data for factories (Laravel: fakerphp/faker)
  gem "faker", "~> 3.5"
  # Style checker, Rails' own default preset (Laravel: Laravel Pint)
  gem "rubocop-rails-omakase", require: false
  # Static analysis for common security issues (Rails ships this by default;
  # closest fit to Larastan, though it checks for vulnerabilities rather than
  # type errors -- see the README for why this template doesn't add a
  # type-level checker like Sorbet)
  gem "brakeman", require: false
end

group :test do
  # sqlite3 backs the test database (see config/database.yml) so the suite
  # runs fast without a MySQL container, the same trade-off both the Laravel
  # and Go versions of this template make.
  gem "sqlite3", "~> 2.1"
  # Derives an OpenAPI document from the request specs as they run (Laravel:
  # Scramble, which infers OpenAPI from FormRequest/Resource type hints
  # instead of from tests)
  gem "rspec-openapi", "~> 0.15"
end
