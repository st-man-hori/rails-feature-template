# Rails Package by Feature Template

[laravel-feature-template](../laravel-feature-template) の Rails 版です。Laravel との比較対象として Rails を体系的に学ぶために作りました。特定プロジェクトのビジネスロジックは含まれておらず、`Task` という汎用的なサンプル機能(CRUD)だけを同梱しています。新規プロジェクトを始めるときはこのリポジトリをベースに `app/features/task` を消して自分たちの Feature を追加してください。

## 思想

Laravel 版・Go 版と同じく、技術的な層(Controller / Service / Repository 等)ではなく機能(Feature)を第一の分割単位とし、1機能 = 1ディレクトリで、Feature 内のコードは原則そのディレクトリの中に閉じ込める構造にしています。

## 技術スタック

- Ruby 3.4 / Rails 8.1(`--api` モード)
- MySQL 8.4(ローカル開発用、Docker Compose で起動)/ テストは sqlite3
- [RSpec](https://rspec.info/) + [request spec](https://relishapp.com/rspec/rspec-rails/docs/request-specs) — テスト(Laravel: PHPUnit / Pest)
- [factory_bot](https://github.com/thoughtbot/factory_bot) + [faker](https://github.com/faker-ruby/faker) — テストデータ(Laravel: database/factories + fakerphp/faker)
- [rubocop](https://github.com/rubocop/rubocop) (rubocop-rails-omakase プリセット) — コードフォーマッタ(Laravel: Laravel Pint)
- [brakeman](https://brakemanscanner.org/) — 静的解析(セキュリティ観点。Larastan との違いは後述)
- [rspec-openapi](https://github.com/exoego/rspec-openapi) — request spec の実行結果から OpenAPI ドキュメントを自動生成(Laravel: Scramble)
- Docker / Docker Compose — ローカル開発環境(`ruby:3.4-slim` ベース。Laravel/Go 版は Alpine ベースだが、Alpine が持つ MariaDB Connector/C は mysql2 gem の `ssl_mode` 指定を無視するバグがあり、MySQL 8 の自己署名証明書で TLS ハンドシェイクに失敗する。Debian 系の `default-libmysqlclient-dev` ではこの問題が起きないため、こちらを採用した。詳細は `docker/app/Dockerfile` と `config/database.yml` のコメントを参照)

## ディレクトリ構成

```
.
├── compose.yaml            # ローカル開発環境の定義
├── docker/app/               # Dockerfile(local/builder/production のマルチステージ)
├── Makefile                  # よく使う操作のショートカット
├── .env.example                # compose.yaml が参照するホスト側の環境変数
├── app/
│   ├── features/              # ここが本体。1機能 = 1パッケージ(ディレクトリ)
│   │   └── task/                # サンプル Feature(CRUD)
│   ├── controllers/
│   │   └── application_controller.rb  # 薄い基底クラス。エラー→JSON変換を集約
│   ├── models/                 # ActiveRecord モデル
│   └── shared/                 # 2つ以上の Feature から使われて初めて置く共通コード
├── config/
│   ├── application.rb          # app/features・app/shared の Zeitwerk 名前空間設定
│   ├── routes.rb                # ルーティング(Feature ごとにブロックを分ける)
│   └── database.yml
├── db/
│   ├── migrate/                 # マイグレーションは本リポジトリで一元管理
│   └── seeds.rb
└── spec/
    ├── requests/api/            # ルーティング構造と対になる統合テスト
    └── factories/
```

## Package by Feature の規約

1機能につき `app/features/{feature}/` を1つ作り、その機能に関するものは原則すべてそのディレクトリの中に閉じ込めます。

```
app/features/{feature}/
├── {feature}_controller.rb   # 薄いコントローラ。1メソッド = 1アクション
├── requests/                  # ActiveModel::Model + Attributes。バリデーション + to_input で Input に変換
├── inputs/                    # UseCase の入力値オブジェクト(Ruby 標準の Data.define)
├── use_cases/                 # ビジネスロジック本体。call を1つ持つ
├── resources/                  # レスポンスの形を決めるクラスメソッド群
└── (services/)                # その Feature 内だけで使うヘルパー(必要な場合)
```

**リクエストの流れ**: `Router → ApplicationController(#underscore_params!) → {Feature}Controller → Request(検証) → Input → UseCase → Model → Resource`

**ルール**

- Repository パターンは使わない。UseCase から ActiveRecord モデルを直接操作する。
- コントローラでの暗黙的な Route Model Binding は使わない(Rails 自体に Laravel のような機能はないが念のため明記)。`params[:id]` を UseCase に渡し、UseCase 側で `find`(見つからなければ `ActiveRecord::RecordNotFound`)する。これにより DB アクセスが UseCase の外に漏れない。
- 「god Service」クラスを作らない。複数 Feature にまたがる共通処理が本当に必要になったときだけ `app/shared/` に切り出す。
- ドメイン固有のエラーは `Shared::Errors::AppError` を継承して作る。`ApplicationController` の `rescue_from` が自動で JSON エラーレスポンスに変換する。
- **`app/features/**/*.rb` と `app/shared/**/*.rb` は必ず `class Features::Task::UseCases::StoreTaskAction` のような compact 形式(1行)で書く。** `module Features; module Task; class ...; end; end; end` という展開形式で書くと、その中で裸の `Task` を参照したときに `Features::Task`(名前空間モジュール自身)が解決されてしまい、`Task` モデルを指せなくなる(Ruby の定数探索は `Module.nesting` に含まれる各モジュールが**自分自身の中に**同名の定数を持っているかを見るのではなく、`Module.nesting` の各階層で「そのモジュール自身が持つ定数」を探すため、`Features` の中で `Task` という定数——つまり `Features::Task` 自身——が見つかってしまう)。`.rubocop.yml` で `Style/ClassAndModuleChildren: EnforcedStyle: compact` を強制しているのはこのため。詳しくは `config/application.rb` のコメントを参照。

新しい Feature を追加するときは `app/features/task/` をコピーしてリネームするのが一番早い方法です。サンプルとして使い終わったら `Task` 一式(`app/features/task`, `app/models/task.rb`, 対応する migration・factory・spec、`config/routes.rb` の該当ブロック)を削除してください。

## なぜ app/features が Zeitwerk の名前空間設定を必要とするのか

Rails(Zeitwerk)は `app/` 直下の各ディレクトリを独立した autoload root として扱い、そのディレクトリ名自体は定数パスに含めません(`app/models/task.rb` が `Models::Task` ではなく `Task` に解決されるのはこのためです)。`app/features` を何もせず追加すると同じルールが適用され、`app/features/task/task_controller.rb` は `Task::TaskController` に解決されて `Task` モデルと衝突します。`config/application.rb` で `app/features` と `app/shared` を通常の autoload path から外し、`Rails.autoloaders.main.push_dir(path, namespace: Features)` で明示的に `Features` / `Shared` 名前空間の下にマウントし直すことでこれを回避しています。動作確認済みの設定なので、新しい Feature ディレクトリを増やす分には何も気にする必要はありません。

## セットアップ

```bash
git clone <this-repo>
cd rails-feature-template

cp .env.example .env

make build
make up
make install     # bundle install
make migrate      # マイグレーション実行
```

`http://localhost:8000` で API が起動します(ポートは `.env` の `APP_PORT` で変更可能)。

## よく使うコマンド(Makefile)

| コマンド | 内容 |
| --- | --- |
| `make up` / `make down` | ローカル環境の起動・停止 |
| `make bash` | app コンテナに入る |
| `make migrate` / `make fresh` / `make seed` | マイグレーション関連 |
| `make test` | RSpec 実行 |
| `make format` / `make format-test` | RuboCop によるフォーマット・チェックのみ |
| `make analyze` | Brakeman による静的解析 |
| `make openapi` | rspec-openapi で `doc/openapi.yaml` を再生成 |
| `make ci` | `format-test` → `analyze` → `test` を一括実行(CI と同じチェック) |

`make help` で一覧を表示できます。

## テストの書き方

- テストは `spec/requests/api/{feature}/` 配下に、ルーティングと対になる形で置きます(`index_spec.rb`, `create_spec.rb` など)。
- 1 ファイル1エンドポイント。
- `Controller → Request → UseCase → DB` を通しで検証する統合テスト(request spec)とし、UseCase 単体のユニットテストは基本的に書きません。
- テスト DB は sqlite3(`config/database.yml` の `test:` セクション、`storage/test.sqlite3`)なので、追加のコンテナなしで高速にテストできます。MySQL 固有の挙動に依存するテストを書く場合は個別に検討してください。`:memory:` ではなくファイルにしているのは、Rails の pending-migration チェック(`maintain_test_schema!`)がスキーマ検証用に別コネクションを開くため、どのコネクションからも見える実体が必要だからです(`config/database.yml` のコメント参照)。トランザクション(`use_transactional_fixtures`)でテスト間の状態をリセットしているため、Laravel の `RefreshDatabase` や Go 版の `testutil.NewDB` ほど徹底した分離(スキーマごと作り直す)ではない点に注意してください。

## CI

`.github/workflows/ci.yml` で `rubocop` / `brakeman` / `rspec` を PR ごとに実行します。デプロイ関連のワークフローは含まれていないので、デプロイ先(ECS, Cloud Run 等)に合わせて別途追加してください。

## Laravel 版との対応

Rails を体系的に学ぶための比較用に、Laravel 版の各要素が Rails 版でどう表現されているかをまとめています。

| Laravel (`laravel-feature-template`) | Rails (`rails-feature-template`) | 補足 |
| --- | --- | --- |
| `routes/api.php` で一元管理 | `config/routes.rb` | どちらもルーティングは一箇所に集約する。Go 版だけ Feature ディレクトリの中にルートを置く方針が違う |
| `TaskController`(Controller) | `Features::Task::TaskController`(Controller) | 薄いレイヤという役割は同じ。Rails のアクション名は `index/show/create/update/destroy` が規約で、Laravel の `store` は `create` に対応する |
| `FormRequest` + `Inputs/`(spatie/laravel-data の `Optional`) | `Requests/`(`ActiveModel::Model` + `ActiveModel::Attributes`)+ `Inputs/`(`Data.define`) | どちらも「検証してから不変の値オブジェクトに変換する」役割。追加 gem なしで Rails 標準の仕組みだけで組める |
| PATCH の「未指定」と「明示的な null」を区別する `Optional`(Go 版は `Field[T]`) | 素の `Hash`(`permitted_params.keys` で判定) | `ActionController::Parameters#permit` はリクエストに存在したキーしか返さないため、Ruby の `Hash` はそのまま「未指定 = キーが無い」「明示的な null = キーはあり値が nil」を表現できる。Optional 相当の専用型が要らない |
| `UseCases/`(1 `execute()` ずつ) | `use_cases/`(1 `call` ずつ) | Repository パターンを使わず ORM を直接叩くという方針も同じ。メソッド名は Ruby の慣習に合わせて `execute` ではなく `call` |
| `Resources/`(`JsonResource`) | `resources/`(クラスメソッドの集まり) | `{"data": ...}` エンベロープも踏襲。インスタンス化せず `TaskResource.to_h(task)` のように直接呼ぶだけの薄い作り |
| Eloquent Model | ActiveRecord Model(`app/models/task.rb`) | ActiveRecord という名前がそのまま指す通り、Eloquent の直接のモデル。バリデーションを書かず Request 層に寄せている点も同じ方針 |
| `AppDomainException` + `ApiErrorResponse` | `Shared::Errors::AppError` + `Shared::Responses::ApiErrorResponse` | `ApplicationController` の `rescue_from` が Laravel の `bootstrap/app.php` の `withExceptions` に相当。Rails では継承チェーンに乗せられるので基底コントローラ自身に書くのが自然 |
| `ForceJsonRequest` / `CamelCaseJsonResponse` ミドルウェア | `ApplicationController#underscore_params!`(`before_action`)+ 各 `Resource` が手動でキーを camelCase で書く | Laravel も出力側は `TaskResource` が手書きで camelCase にしており、ミドルウェアは主にページネーション meta 等のフレームワーク生成部分を救うためのもの。Rails 版は meta もコントローラで自前生成するため出力側ミドルウェアが要らず、入力側だけ 1 つの `before_action` で `params.deep_transform_keys!(&:underscore)` すれば足りる |
| `database/migrations`(Laravel Migration、PHP で記述) | `db/migrate/*.rb`(Rails Migration) | 「マイグレーションを一元管理する」という思想は同じ。テスト用の sqlite スキーマは Rails が `db/schema.rb` として自動生成・同期する(`ActiveRecord::Migration.maintain_test_schema!`) |
| `RefreshDatabase` + SQLite in-memory | `use_transactional_fixtures` + sqlite(ファイル) | 高速なテストのために本番と違う DB を使う狙いは同じ。Rails はスキーマを作り直すのではなく、各 example をトランザクションで囲んでロールバックする方式。sqlite が `:memory:` ではなくファイルなのは `maintain_test_schema!` が別コネクションでスキーマを検証するため |
| サービスコンテナによる自動 DI | `UseCase.new` を Controller から直接呼ぶだけの手動ワイヤリング | Rails にも DI コンテナ的な仕組みはあるが、この規模のアプリでは Laravel のようなコンストラクタインジェクションの恩恵が薄いため、素朴に `new` する |
| Laravel Pint | RuboCop(rubocop-rails-omakase プリセット) | どちらも「議論の余地がない」フォーマッタ。omakase は Rails コアチームが公開している既定値で、独自ルールをほぼ持ち込まない思想が Pint の Laravel プリセットに近い |
| Larastan(PHPStan level 7) | Brakeman | ここだけは同じ役割ではない。Larastan は型レベルの静的解析だが、Ruby 未経験者向けのこのテンプレートでは Sorbet/RBS のような型注釈の追加コストを払わない判断をした。Brakeman はセキュリティ観点(SQLインジェクション、Mass Assignment 等)の静的解析で、型チェックの代替にはならない点に注意 |
| Scramble(コードから自動で OpenAPI 生成) | rspec-openapi(request spec の実行結果から自動生成) | どちらも手書きの OpenAPI アノテーション不要という点は同じだが、情報源が違う。Scramble は FormRequest/Resource の型情報から静的に生成し、rspec-openapi は実際にテストを実行して観測したリクエスト/レスポンスから生成する。後者は「テストで叩いていないパターンはドキュメントに出ない」ことに注意 |
| `php artisan serve` / 本番の PHP-FPM + nginx | 単一の Puma サーバー(`bin/rails server`) | Rails の Web サーバー(Puma)は Go と同様にそれ自体で本番運用できるレベルにあるため、PHP-FPM と nginx のようなプロセス分割が要らない。`compose.yaml` の `app` サービスが1つで済むのもこのため |
| `.env` + `config:cache` | 起動時に `ENV` を読む `config/database.yml` の ERB | Rails は Laravel の `config:cache` のような明示的なキャッシュ手順を必要としない。ただし Rails 独自の `config/credentials.yml.enc` の仕組みは、このテンプレートでは使う秘匿情報が無いため削除した |

## フレームワークについて

Laravel と同じく Rails も「これ一択」という強いフレームワーク文化を持つため、Go 版のように標準ライブラリ + 軽量ライブラリを組み合わせる必要はありません。ActiveRecord・ルーティング・コントローラなど、この template が使っているものはほぼ全て Rails 本体(または `rails new` が標準で入れる gem)です。追加した gem は RSpec 系(テスト)、factory_bot/faker(テストデータ)、rubocop-rails-omakase/brakeman(静的解析)、rspec-openapi(ドキュメント生成)のみで、いずれも Rails コミュニティで広く使われている定番です。
