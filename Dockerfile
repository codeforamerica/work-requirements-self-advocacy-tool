# syntax=docker/dockerfile:1
# check=error=true

# This Dockerfile is designed for production, not development. Use with Kamal or build'n'run by hand:
# docker build -t work_requirements_self_advocacy_tool .
# docker run -d -p 80:80 -e RAILS_MASTER_KEY=<value from config/master.key> --name work_requirements_self_advocacy_tool work_requirements_self_advocacy_tool

# For a containerized dev environment, see Dev Containers: https://guides.rubyonrails.org/getting_started_with_devcontainer.html

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version
ARG RUBY_VERSION=3.4.11
# Node version, within the 22.x line that package.json engines, .tool-versions and CI
# require. Doubles as the tag of the DHI Node image that Node is copied from (see the
# node stage below), so like RUBY_VERSION it has to name a tag DHI actually publishes.
# Pinned so Node only changes in a reviewed bump: nothing updates it automatically,
# so bump it by hand for Node security releases. DHI still rebuilds the tag in place
# for OS-level patches, so the image digest is not fixed.
ARG NODE_VERSION=22.23.4

# Chrome for Testing build that Grover drives through Puppeteer, plus the
# @puppeteer/browsers release used to fetch it. A manual pin, independent of the
# build Puppeteer targets, so we can take a Chrome security release without waiting
# for a Puppeteer release -- but it only moves when someone bumps it. See the
# "Chrome" section of the README before bumping.
ARG CHROME_VERSION=155.0.8059.79
ARG PUPPETEER_BROWSERS_VERSION=2.13.2

# Source of the Node runtime copied into the base stage. -dev is the variant that
# ships npx and yarn alongside node.
FROM dhi.io/node:$NODE_VERSION-dev AS node

# Docker Hardened Image, per https://docs.docker.com/guides/ruby/. Not a public
# image -- building requires `docker login dhi.io` first. See the README.
# This tag is Debian 13 (trixie); the 3.4.4 tag was still on Debian 12.
FROM dhi.io/ruby:$RUBY_VERSION-dev AS base

# Rails app lives here
WORKDIR /rails

ARG CHROME_VERSION
ARG PUPPETEER_BROWSERS_VERSION

ENV PUPPETEER_CACHE_DIR="/opt/puppeteer"

# Install base packages. Runtime only: libpq5 rather than libpq-dev (the headers are
# needed to build the pg gem, not to run it), no libvips since Active Storage variant
# processing is disabled, and no postgresql-client since db:prepare goes through the
# pg gem rather than psql. passwd supplies the groupadd/useradd the final stage needs,
# and curl stays for anything that probes the running container; the hardened base
# ships neither.
# ca-certificates is not optional either: the base carries a CA bundle that dpkg does
# not own, so the first apt install triggers update-ca-certificates and rewrites that
# bundle from an empty source, breaking TLS for curl and git until the real package is
# in place.
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y ca-certificates curl libjemalloc2 libpq5 passwd && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy Node in from the DHI Node image. Grover shells out to Puppeteer to render PDFs,
# so Node is a runtime dependency and belongs in the base stage rather than only in
# the build stage. Debian packages Node 20, which is both EOL upstream and below the
# 22.x that package.json requires.
#
# This used to apt-install NodeSource's nodejs package, which declares a hard
# dependency on python3 (for node-gyp, which nothing here needs). That made every Node
# install negotiate python3 and ncurses versions against the hardened base, and broke
# the build whenever the DHI apt repository moved ahead of the base image. Copying the
# files keeps apt out of it entirely. The DHI build is a single node binary that links
# only against libc, libm, libstdc++ and libgcc_s, all already in the Ruby base. Both
# images are DHI Debian 13, so the libraries match.
#
# Only the commands this image runs get linked onto the PATH: npx for the Chrome
# install below, and yarn for the build stage. npx lives inside npm's package, so all
# of npm comes along, but nothing here calls npm itself. The DHI image also ships
# corepack, which is left out since package.json has no packageManager field.
COPY --from=node /usr/bin/node /usr/bin/node
COPY --from=node /usr/lib/nodejs/npm /usr/lib/nodejs/npm
COPY --from=node /usr/lib/nodejs/yarn /usr/lib/nodejs/yarn
RUN ln -s ../lib/nodejs/npm/bin/npx-cli.js /usr/bin/npx && \
    ln -s ../lib/nodejs/yarn/bin/yarn /usr/bin/yarn && \
    node --version && npx --version && yarn --version

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

# Set production environment. No PUPPETEER_SKIP_DOWNLOAD: the app depends on
# puppeteer-core, which never fetches a browser of its own, so there is nothing to
# skip. Grover reads PUPPETEER_EXECUTABLE_PATH itself (config/initializers/grover.rb)
# and points Chrome at the build we installed above.
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development" \
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
