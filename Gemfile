source "https://rubygems.org"

gem "rails", "~> 8.1.3", ">= 8.1.3.1"
# Active Record 用データベース(開発・本番)。テストは sqlite3 を使う
# (下の :test グループを参照)
gem "mysql2", "~> 0.5"
# Puma Web サーバー [https://github.com/puma/puma]
gem "puma", ">= 5.0"

# Windows は zoneinfo ファイルを含まないため tzinfo-data を同梱する
gem "tzinfo-data", platforms: %i[ windows jruby ]

# require/load-path の処理をキャッシュして起動を高速化する
gem "bootsnap", require: false

# CORS(Cross-Origin Resource Sharing)を扱う場合は Rack CORS を有効化する
# gem "rack-cors"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # request spec(Laravel: PHPUnit / Pest)
  gem "rspec-rails", "~> 8.0"
  # モデルのファクトリ(Laravel: database/factories)
  gem "factory_bot_rails", "~> 6.4"
  # ファクトリ用のダミーデータ生成(Laravel: fakerphp/faker)
  gem "faker", "~> 3.5"
  # Rails 公式のデフォルトプリセットによるスタイルチェッカー(Laravel: Laravel Pint)
  gem "rubocop-rails-omakase", require: false
  # 代表的なセキュリティ脆弱性を検出する静的解析ツール(Rails のデフォルト
  # 同梱ツール)。Larastan に最も近い立ち位置だが、型エラーではなく
  # 脆弱性を検出するものなので役割は異なる。このテンプレートで Sorbet の
  # ような型チェッカーを入れていない理由は README を参照
  gem "brakeman", require: false
end

group :test do
  # テスト用データベースは sqlite3(config/database.yml 参照)。追加の
  # データベースコンテナなしで高速にテストを回せる、という Laravel 版・
  # Go 版と同じトレードオフ
  gem "sqlite3", "~> 2.1"
  # request spec の実行結果から OpenAPI ドキュメントを自動生成する
  # (Laravel: Scramble。ただし Scramble は FormRequest/Resource の
  # 型情報から静的に生成する点が異なる)
  gem "rspec-openapi", "~> 0.15"
end
