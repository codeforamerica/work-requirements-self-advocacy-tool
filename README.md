# Work Requirements Self Advocacy Tool

## Setup

If it's your first time setting up for local development, you will need to have the following installed:

* brew (https://brew.sh/)
* git (https://git-scm.com/downloads)
* Docker (https://docs.docker.com/get-docker/)

1. In the root directory of this project, run the setup script:
    >$ ./bin/setup


2. Navigate to http://localhost:3000. You should see your app!

## Running the application subsequently

1. In the root directory of this project, run the dev script:

   >$ ./bin/dev

## Running the Linter

To run the linter locally, run the following command: `bundle exec standardrb --fix`. If you forget to do this, the linter will run when a pull request is opened. To ignore the linter, here is a [guide](https://github.com/standardrb/standard?tab=readme-ov-file#ignoring-errors).
