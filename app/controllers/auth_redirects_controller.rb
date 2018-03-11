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
        # create or update Team object, and store relevant tokens
        new_team_data = response.to_hash.symbolize_keys
        new_team_data.delete(:ok) # don't need the :ok value

        # flatten the 'bot' hash
        new_team_data[:bot_user_id] = response[:bot][:bot_access_token]
        new_team_data[:bot_access_token] = response[:bot][:bot_access_token]
        new_team_data.delete(:bot)

        Team.create(new_team_data)

        render body: "Hi #{new_team_data[:team_name]}! Thanks for installing \"Let's Hang\"!", status: status

        # # testing
        # Slack.configure do |config|
        #   config.token = bot_access_token
        #   config.logger = Rails::logger
        # end
        # client = Slack::Web::Client.new

        # # testing what we can do with the different tokens
        # require 'pry'; binding.pry
        # response = client.conversations_open({return_im: true, users: user_id})
        # require 'pry'; binding.pry
        # client.chat_postMessage(
        #   channel: response[:channel][:id],
        #   text: "Thanks for installing Let's Hang!",
        #   as_user: false
        # )
      else
        # redirect to some error page?
      end
   end
  end

end
