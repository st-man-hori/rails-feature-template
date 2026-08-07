require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
# require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

# Top-level namespaces for app/features and app/shared (see the
# config.before_configuration block below for why these need a custom
# Zeitwerk root instead of the default app/* autoload behavior).
module Features
end

module Shared
end

module RailsFeatureTemplate
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    # By default every directory directly under app/ becomes its own
    # flattened Zeitwerk autoload root -- this is why app/models/task.rb
    # resolves to `Task` instead of `Models::Task`. Left alone, app/features
    # would flatten the same way, and app/features/task/task_controller.rb
    # would resolve to `Task::TaskController`, colliding with the `Task`
    # model. Pull both custom directories out of the default autoload paths
    # and re-mount them under explicit namespaces instead.
    features_path = "#{Rails.root}/app/features"
    shared_path = "#{Rails.root}/app/shared"
    config.autoload_paths -= [ features_path, shared_path ]
    config.eager_load_paths -= [ features_path, shared_path ]

    config.before_configuration do
      Rails.autoloaders.main.push_dir(features_path, namespace: Features)
      Rails.autoloaders.main.push_dir(shared_path, namespace: Shared)
    end
  end
end
