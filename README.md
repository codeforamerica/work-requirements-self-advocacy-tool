# Work Requirements Self Advocacy Tool

## Setup

If it's your first time setting up for local development, do the following steps:

1. In the root directory, initialize `rbenv`:

    $ rbenv init

2. Run the setup script:

    $ bin/setup

3. Start the server:

    $ foreman start

4. Navigate to http://localhost:3000. You should see your app!

## Running the Linter

To run the linter locally, run the following command: `bundle exec standardrb --fix`. If you forget to do this, the linter will run when a pull request is opened. To ignore the linter, here is a [guide](https://github.com/standardrb/standard?tab=readme-ov-file#ignoring-errors).
