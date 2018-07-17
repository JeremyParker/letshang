# LETSHANG

## Local development

For local development tunnel internet traffic to your local box by running `ngrok http 3000`
This will tell you what public address is being tunneled to your local machine. For example, `https://77f55955.ngrok.io`.
That public address will be the <server_address> in configurations below.

Get the .envrc file, which defines the following environment variables:
```
SLACK_CLIENT_ID
SLACK_CLIENT_SECRET
SLACK_VERIFICATION_TOKEN
SLACK_OAUTH_ACCESS_TOKEN
SLACK_BOT_USER_TOKEN
```

* Make sure `direnv` is installed. It will execute that file when you switch to that directory. This is how all those environment variables get set in your local shell.
* Make sure `docker` and `docker-compose` are installed.
* Run `docker-compose build`
* Run `docker-compose up`
* The environment variables listed in the `docker-compose.yml` file are copied from your local shell to the docker environment.

To debug
- put a `require'pry'; binding.pry` statement in the code
- run `docker ps` in a local shell
- note the process number of the web service, and run `docker attach 75cde1ab8133` with the web service pid.
- when the breakpoint is hit, you should be in an interactive session
- when you're done debugging run `exit` to continue execution
- to dettach hit `ctrl-p` + `ctrl-q`.

## Setting up public server

Run the server software somewhere and expose it at a particular address. That address will be <server_address> below.

**Set Up The App And Environment Variables:**

Go to https://api.slack.com/apps and choose the `Let'sHang` app (or create it if needed)
For me that's https://api.slack.com/apps/A9KSX926M for dev, and https://api.slack.com/apps/ABDL47QDN in the PP workspace for prod.

Go to the Basic Information option from the left hand nav bar.
Installed components are
- Slash Commands
- Bots
- Interactive Components
- Permissions

Make sure the environment variable SLACK_CLIENT_ID is set to the app's `Client ID`
Set SLACK_CLIENT_SECRET to the app's `Client Secret`
Set SLACK_VERIFICATION_TOKEN to the app's `Verification Token`
App Name should be `Let'sHang` and Short Description is "Making it easier to go out with friends"
At this time the color is #054fe3

Select `Interactive Components` from the left hand nav bar
In the form, enter <server_address>/slack_submission in the `Request URL` field

Select `Slash Commands` from the left hand nav bar
Make sure there's a `/letshang` command there.
Ensure that the Request URL is <server_address>/slack_slash_command
Short description should be `Starts making a plan for you and your friends`
Usage hint should be `Just type /letshang and let the bot guide you through the process.`
`Escape channels, users, and links sent to your app` should be checked.

Select `OAth & Permissions` from the left hand nav bar.
Make sure the Redirect URLs include <server_address>/auth_redirects.
TODO: finalize what scopes we need.

Select `Bot Users` from the left hand nav bar
There should be a bot user whose `Display Name` is Let'sHang and whose default username is letshang.

Select User ID Translation.
Translate Global IDs should be on.

* Database management
`rake db:migrate` after every change.

* Database initialization

