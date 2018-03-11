# Controller to handle when the user hits the 'Intall App' Slack button, then
# gets redirected here with a code.

class AuthRedirectsController < ApplicationController

  # GET /auth_redirects
  def index
    if params[:code]
      client_id = ENV['SLACK_CLIENT_ID']
      client_secret = ENV['SLACK_CLIENT_SECRET']
      code = params[:code]

      Slack.configure do |config|
        config.logger = Rails::logger
      end
      client = Slack::Web::Client.new

      options = {
        client_id: client_id,
        client_secret: client_secret,
        code: code
      }
      response = client.oauth_access(options)

      if response[:ok]
        access_token = response[:access_token]
        scope = response[:scope]
        user_id = response[:user_id] # flavri is 'U02CWFEEJ'
        team_name = response[:team_name]
        team_id = response[:team_id]
        bot_user_id = response[:bot][:bot_user_id]
        bot_access_token = response[:bot][:bot_access_token]

        # testing
        Slack.configure do |config|
          config.token = bot_access_token
          config.logger = Rails::logger
        end
        client = Slack::Web::Client.new

        # testing what we can do with the different tokens
        require 'pry'; binding.pry
        response = client.conversations_open({return_im: true, users: user_id})
        require 'pry'; binding.pry
        client.chat_postMessage(
          channel: response[:channel][:id],
          text: "Thanks for installing Let's Hang!",
          as_user: false
        )

        # create or update Team object, and store relevant tokens

      else
        # redirect to some error page?
      end
   end
  end

end
