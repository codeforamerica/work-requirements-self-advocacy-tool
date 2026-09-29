# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t work_requirements_self_advocacy_tool .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name work_requirements_self_advocacy_tool work_requirements_self_advocacy_tool

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.10
# Node major line, matching package.json engines, .tool-versions and CI. Debian only
# packages Node 20, so this comes from NodeSource (see the base stage below). The
# patch floats within the line so rebuilds pick up Node's security releases; pin it at
# the apt install (nodejs=22.23.2-1nodesource1) if a build ever needs to be exactly
# reproducible.
ARG NODE_MAJOR=22
ARG YARN_VERSION=1.22.22

# Chrome for Testing build that Grover drives through Puppeteer, plus the
# @puppeteer/browsers release used to fetch it. Pinned to the current Chrome stable
# rather than to the build Puppeteer pins for itself: Grover does not support
# Puppeteer 25 yet (see .github/dependabot.yml), and Puppeteer 24 pins a Chrome that
# is several releases behind. See the "Chrome" section of the README before bumping.
ARG CHROME_VERSION=153.0.8010.36
ARG PUPPETEER_BROWSERS_VERSION=2.13.2

# Docker Hardened Image, per https://docs.docker.com/guides/ruby/. Not a public
# image -- building requires `docker login dhi.io` first. See the README.
# This tag is Debian 13 (trixie); the 3.4.4 tag was still on Debian 12.
FROM dhi.io/ruby:$RUBY_VERSION-dev AS base

# Rails app lives here
WORKDIR /rails

ARG CHROME_VERSION
ARG NODE_MAJOR
ARG PUPPETEER_BROWSERS_VERSION
ARG YARN_VERSION

ENV PUPPETEER_CACHE_DIR="/opt/puppeteer"

# Install base packages. Runtime only: libpq5 rather than libpq-dev (the headers are
# needed to build the pg gem, not to run it), no libvips since Active Storage variant
# processing is disabled, and no postgresql-client since db:prepare goes through the
# pg gem rather than psql. curl fetches the NodeSource signing key below, and passwd
# supplies the groupadd/useradd the final stage needs; the hardened base ships neither.
# ca-certificates is not optional either: the base carries a CA bundle that dpkg does
# not own, so the first apt install triggers update-ca-certificates and rewrites that
# bundle from an empty source, breaking TLS for curl and git until the real package is
# in place.
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y ca-certificates curl libjemalloc2 libpq5 passwd && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install Node from NodeSource. Grover shells out to Puppeteer to render PDFs, so Node
# is a runtime dependency and belongs in the base stage rather than only in the build
# stage. Debian packages Node 20, which is both EOL upstream and below the 22.x that
# package.json requires, so NodeSource is the apt route to the version this app runs
# on. The key is stored armored and referenced with signed-by, so it authenticates
# only this repository and no gnupg is needed to dearmor it.
RUN install -d /etc/apt/keyrings && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key \
      -o /etc/apt/keyrings/nodesource.asc && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.asc] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" \
      > /etc/apt/sources.list.d/nodesource.list && \
    apt-get update -qq && \
    apt-get install --no-install-recommends -y nodejs && \
    npm install -g yarn@$YARN_VERSION && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives /root/.npm

# Install Chrome the way the official Puppeteer image does
# (https://github.com/puppeteer/puppeteer/blob/main/docker/Dockerfile): download a
# Chrome for Testing build, then `apt-get satisfy` exactly the shared libraries that
# build declares it needs. We used to apt-install the Debian chromium package purely
# to pull in those libraries, which left a second, independently-patched browser in
# the image -- both of them showing up in Inspector as embedded Chrome.
#
# The fonts are a deliberate swap. The PDF stylesheet asks for "Source Sans 3",
# which is not installed, so Chrome falls back to the system sans-serif. The Debian
# chromium package used to supply that as DejaVu Sans; Chrome's own deb.deps supplies
# Liberation Sans, which is narrower and would reflow every generated packet. Keep
# DejaVu so this stays a security change and PDFs render as they do today.
RUN apt-get update -qq && \
    npx --yes @puppeteer/browsers@$PUPPETEER_BROWSERS_VERSION \
      install chrome@$CHROME_VERSION --install-deps --path "$PUPPETEER_CACHE_DIR" && \
    apt-get install --no-install-recommends -y fonts-dejavu-core && \
    apt-get remove -y --purge fonts-liberation && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives /root/.npm

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
    PUPPETEER_SKIP_DOWNLOAD="true" \
    PUPPETEER_EXECUTABLE_PATH="$PUPPETEER_CACHE_DIR/chrome/linux-$CHROME_VERSION/chrome-linux64/chrome"

# Fail the build here rather than at PDF-render time if that cache layout changes.
RUN "$PUPPETEER_EXECUTABLE_PATH" --version

# Throw-away build stage to reduce size of final image
FROM base AS build

# Install packages needed to build gems and node modules
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY .ruby-version Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Install node modules
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompiling assets for production without requiring secret RAILS_MASTER_KEY
RUN \
  SECRET_KEY_BASE_DUMMY=1 \
  ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=dummy \
  ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=dummy \
  ACTIVE_RECORD_DERIVATION_SALT_KEY=dummy \
  ./bin/rails assets:precompile

# Final stage for app image
FROM base

# Copy built artifacts: gems, application
COPY --from=build "${BUNDLE_PATH}" "${BUNDLE_PATH}"
COPY --from=build /rails /rails

# Run and own only the runtime files as a non-root user for security
RUN groupadd --system --gid 1000 rails && \
    useradd rails --uid 1000 --gid 1000 --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER 1000:1000

# Entrypoint prepares the database.
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Start server via Thruster by default, this can be overwritten at runtime
ENV THRUSTER_HTTP_PORT=8080
EXPOSE 8080
CMD ["./bin/thrust", "./bin/rails", "server"]
