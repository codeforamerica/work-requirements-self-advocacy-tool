# Work Requirements Self Advocacy Tool

## Development Setup

The recommended development setup uses [`mise`](https://mise.jdx.dev/).

On MacOS, using `zsh`:

1. Install `mise`

         $ brew install mise

2. Modify `.zshrc`:

        $ echo 'eval "$(/opt/homebrew/bin/mise activate zsh)"' >> ~/.zshrc

3. Install dependencies:

        $ brew install libyaml pkgconf icu4c

4. Force link `icu4c` (`mise` won't find it otherwise):

        $ brew link icu4c --force

5. In the root directory of the project, install development tools:

        $ mise install

6. Start Postgres:

        $ pg_ctl start

7. Create a new database:

        $ bin/rails db:create

## Running Locally

From the root directory of the project:

1. Start Postgres:

      $ pg_ctl start

2. Start the Rails server:

      $ bin/rails serve

Now, navigate to http://localhost:3000. You should see you Rails app!
