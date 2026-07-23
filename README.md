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

## Testing emails

To send a test email, you can deploy the application to the staging environment and send an email to a verified identity.

* Let the team know that you're going to use staging and that no one should merge into `main`
  * This is because merging into `main` automatically triggers a deployment to staging, and will overwrite your branch 
* in GitHub, go to Actions > Deploy to AWS
* in the "Run workflow" menu:
  * Use workflow from: `your branch`
  * The environment to deploy to: `staging`
  * The branch of the infrastructure repository to deploy: `main`
* when the deploy is finished, go to the staging development environment and trigger your email
  * you can use the GBH eng team's google group email, it is verified
 
#### What if you'd like to test an email that is scheduled and not sent immediately? 

* Let the team know that you're going to use staging and that no one should merge into `main`
* In your branch, you can change _when_ the recurring email will be sent by modifying `recurring.yml` under the `Staging:` section
  * You can also, if necessary, tweak the query/queries being used to pull the correct data for testing purposes
* Deploy your branch, as above, to `staging`
* Test as above
* Confirm your (modified) scheduled email(s) send as expected
  * Use this process to iterate, making sure you can get emails for all use cases, translations, etc without errors/alerts in Datadog and Slack
* Revert your changes in your branch and redeploy to `staging`
* Test again, leaving your branch on `staging` until the job runs as originally scoped in `recurring.yml`


## Access to Database

Locally, you can use `bin/rails console`

On Heroku, you can use `heroku run rails c -a <review-app-name>`

On Staging and Production, use the `bin/ecs_exec` script.

### Using bin/ecs_exec script to connect to Staging or Production

#### Prerequisites:

* You must have `awscli` installed on your machine already (check with `aws --version`).
If not, `brew install awscli` on your local machine ([AWS instructions here](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)).
Please download the [AWS Session Manager as well following AWS instructions](https://docs.aws.amazon.com/systems-manager/latest/userguide/install-plugin-macos-overview.html)

* You need an `AWS_PROFILE` for Work Requirements (for both Prod and Non-Prod AWS accounts). [Follow AWS Identity Center: Configuring SSO instructions](https://www.notion.so/cfa/AWS-Identity-Center-e8a28122b2f44595a2ef56b46788ce2c?source=copy_link#ef1c6c77703b4215bbe1953de4692054) to configure your profile correctly.
  * For your Production profile use `wrsat-prod`
  * For your Staging profile use `wrsat-nonprod`

⚠️ It is important to name your profiles _exactly_ as above, as the script will not work if (for example) your profile is named `wrsat-non-prod`. You can rename your aws profile by editing your `~/.aws/config` and `~/.aws/credentials`.

#### Connecting:

1. Make sure you're logged into aws: `aws sso login`. This should open up an AWS console and have you sign in (if you aren't signed in already). After verification, it'll return you to the terminal
2. For staging, you can use `bin/ecs_exec`
3. For production, you can pass in `bin/ecs_exec --env production`
4. You can pass in other parameters like:
   1. `--desired-status`: `RUNNING` by default, but can specify `STOPPED`. See documentation for [list-tasks](https://docs.aws.amazon.com/cli/latest/reference/ecs/list-tasks.html).
   2. `--command`: if you want to run something other than `bin/sh`
   3. There are other commands that the aws ecs can call. The options can be passed manually into the `list-tasks` ([doc](https://docs.aws.amazon.com/cli/latest/reference/ecs/list-tasks.html)) and `execute-command`([doc](https://docs.aws.amazon.com/cli/latest/reference/ecs/execute-command.html)) commands. See linked documentation.
5. Type in `bin/rails c --sandbox` (remove `--sandbox` if you must perform operations that will write/modify data in the db; please pair/try to be loud as possible when performing a write operation)
   1. When you start rails console, it will say `Loading production environment (Rails <version>)` for both staging AND production. This is because we don't explicitly set a `staging` environment for the RAILS_ENV in our app, to make sure that the environments are similar as possible (We use `REVIEW_APP` to specify heroku/staging environments against the production environment).

---
