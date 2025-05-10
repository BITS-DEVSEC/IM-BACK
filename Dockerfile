# syntax = docker/dockerfile:1

# Match RUBY_VERSION with your .ruby-version and Gemfile
ARG RUBY_VERSION=3.4.2
FROM docker.io/library/ruby:${RUBY_VERSION}-slim AS base

# Set working directory
WORKDIR /opt/app

# Throw-away build stage for gem installation
FROM base AS build

# Install build dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    libvips \
    pkg-config \
    libxml2-dev \
    libxslt1-dev \
    libyaml-dev

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copy application code
COPY . .

# Ensure bin scripts are executable
RUN chmod +x bin/rubocop bin/brakeman

# Precompile bootsnap for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Final stage for runtime image
FROM base

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libvips \
    postgresql-client \
    libjemalloc2 \
    libyaml-0-2 && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy built artifacts from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /opt/app /opt/app

# Ensure bin scripts are executable in final image
RUN chmod +x /opt/app/bin/rubocop /opt/app/bin/brakeman

COPY bin/docker-entrypoint /opt/app/bin/docker-entrypoint
RUN chmod +x /opt/app/bin/docker-entrypoint

# Create and switch to non-root user
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp /opt/app/bin/docker-entrypoint /opt/app/bin/rubocop /opt/app/bin/brakeman
USER rails:rails

# Entrypoint to handle database setup
ENTRYPOINT ["/opt/app/bin/docker-entrypoint"]

# Expose port and start server
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]