# Declare a build argument for Ruby version
ARG RUBY_VERSION

# Use the argument in the FROM instruction
FROM ruby:${RUBY_VERSION}-slim

# Set environment variables and enable bundler settings
ENV BUNDLE_APP_CONFIG="/usr/local/bundle" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_BIN="/usr/local/bundle/bin" \
    PATH="$BUNDLE_BIN:$PATH"

# Install essential dependencies
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    yarn \
    git \
    curl \
    ca-certificates \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create a directory for the Rails app
WORKDIR /workspace

# Copy Gemfile and Gemfile.lock to leverage Docker caching
COPY Gemfile* /workspace/

# Install gems based on Gemfile
RUN bundle install --jobs=4 --retry=3

# Copy application code
COPY . /workspace

# Expose port 3000 for the Rails server
EXPOSE 3000

# Start the Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]