# syntax=docker/dockerfile:1

FROM ruby:3.4-slim AS base

# mysql2 needs a MySQL-compatible client library to build/link against.
# Alpine only ships MariaDB Connector/C, and that combination has a known
# SSL bug with this gem: `ssl_mode: disabled` is silently ignored, so the
# client still negotiates TLS and then rejects MySQL 8's self-signed cert.
# Debian's default-libmysqlclient-dev doesn't have that problem, so this
# template uses ruby:*-slim instead of the Alpine images the Laravel and Go
# versions use.
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
        build-essential \
        default-libmysqlclient-dev \
        pkg-config \
        git \
        tzdata \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# --- local: bind-mounted source (see compose.yaml). Gems are installed at
# container start, not at build time -- compose.yaml sets BUNDLE_PATH to
# vendor/bundle (bundler's answer to Composer's vendor/) so `bundle install`
# writes into the bind mount and persists on the host, the same as the
# Laravel version's ./src/vendor -----------------------------------------
FROM base AS local

CMD ["bin/rails", "server", "-b", "0.0.0.0", "-p", "3000"]

# --- builder: installs only production gems, then copies the app in ------
FROM base AS builder

ENV BUNDLE_WITHOUT="development:test"

COPY Gemfile Gemfile.lock ./
RUN bundle install && rm -rf /usr/local/bundle/cache

COPY . .

RUN bundle exec bootsnap precompile app/ lib/ config/

# --- production: runtime libs only, compiled bundle + app, non-root user -
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
