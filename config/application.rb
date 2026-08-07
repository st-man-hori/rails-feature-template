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

# app/features と app/shared のトップレベル名前空間(下の
# config.before_configuration ブロックで、なぜこの2つだけ app/* の
# デフォルトのオートロード挙動ではなくカスタムの Zeitwerk root が必要
# なのかを説明している)。
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

    # デフォルトでは app/ 直下の各ディレクトリはそれぞれ独立した、
    # フラット化された Zeitwerk のオートロード root になる -- これが
    # app/models/task.rb が `Models::Task` ではなく `Task` に解決される
    # 理由。何もしなければ app/features も同じようにフラット化され、
    # app/features/task/task_controller.rb は `Task::TaskController` に
    # 解決されて `Task` モデルと衝突してしまう。そこでこの2つのディレク
    # トリだけデフォルトのオートロードパスから外し、明示的な名前空間の
    # 下に付け替える。
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
