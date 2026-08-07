.DEFAULT_GOAL := help

.PHONY: help up down build rebuild bash install migrate fresh seed test format format-test analyze openapi ci

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-16s\033[0m %s\n", $$1, $$2}'

up: ## Start the local environment
	docker compose up -d

down: ## Stop the local environment
	docker compose down

build: ## Build (or rebuild) the images
	docker compose build

rebuild: ## Rebuild images from scratch and restart
	docker compose down
	docker compose build --no-cache
	docker compose up -d

bash: ## Open a shell in the app container
	docker compose exec app sh

install: ## bundle install
	docker compose exec app bundle install

migrate: ## Run migrations
	docker compose exec app bin/rails db:migrate

fresh: ## Drop all tables and re-run migrations
	docker compose exec app bin/rails db:migrate:reset

seed: ## Run database seeders
	docker compose exec app bin/rails db:seed

test: ## Run the test suite
	docker compose exec app bundle exec rspec

format: ## Fix code style with RuboCop
	docker compose exec app bundle exec rubocop -a

format-test: ## Check code style without fixing
	docker compose exec app bundle exec rubocop

analyze: ## Run static analysis with Brakeman
	docker compose exec app bundle exec brakeman -q

openapi: ## Regenerate the OpenAPI schema (doc/openapi.yaml) via rspec-openapi
	docker compose exec app sh -c "OPENAPI=1 bundle exec rspec"

ci: format-test analyze test ## Run the same checks as CI
