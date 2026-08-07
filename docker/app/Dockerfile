# syntax=docker/dockerfile:1

FROM ruby:3.4-slim AS base

# mysql2 のビルドには MySQL 互換のクライアントライブラリが必要。Alpine が
# 持っているのは MariaDB Connector/C で、この組み合わせには既知の SSL
# バグがある: `ssl_mode: disabled` を指定しても無視され、クライアントは
# TLS ハンドシェイクを試みて MySQL 8 の自己署名証明書を拒否してしまう。
# Debian の default-libmysqlclient-dev ではこの問題が起きないため、
# Laravel/Go 版が使う Alpine イメージではなく ruby:*-slim を使っている。
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
        build-essential \
        default-libmysqlclient-dev \
        pkg-config \
        git \
        tzdata \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# --- local: ソースはバインドマウント(compose.yaml参照)。gem はビルド時では
# なくコンテナ起動時にインストールする -- compose.yaml で BUNDLE_PATH を
# vendor/bundle(Composer の vendor/ に相当)に設定しているので、`bundle
# install` はバインドマウント先(=ホスト側)に書き込まれ、Laravel 版の
# ./src/vendor と同じようにホストに残る -----------------------------------
FROM base AS local

CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]

# --- builder: 本番用の gem だけをインストールしてからアプリ本体をコピー ---
FROM base AS builder

ENV BUNDLE_WITHOUT="development:test"

COPY Gemfile Gemfile.lock ./
RUN bundle install && rm -rf /usr/local/bundle/cache

COPY . .

RUN bundle exec bootsnap precompile app/ lib/ config/

# --- production: 実行に必要なライブラリのみ + コンパイル済み bundle と
# アプリ本体、非 root ユーザーで実行 ---------------------------------------
FROM ruby:3.4-slim AS production

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
        libmariadb3 \
        tzdata \
    && rm -rf /var/lib/apt/lists/* \
    && groupadd -g 1000 rails \
    && useradd -m -u 1000 -g rails rails

WORKDIR /app

COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1 \
    BOOTSNAP_CACHE_DIR=/app/tmp/cache/bootsnap

RUN chown -R rails:rails /app
USER rails

EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]
