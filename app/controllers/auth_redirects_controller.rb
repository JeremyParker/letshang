# Controller to handle when the user hits the 'Intall App' Slack button, then
# gets redirected here with a code.

class AuthRedirectsController < ApplicationController
  protect_from_forgery :except => [:index] # they don't send us any token :(

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

        Team.create_or_update(new_team_data)

        render body: "Hi #{new_team_data[:team_name]}! Thanks for installing \"Let's Hang\"!", status: status
      else
        # TODO: redirect to some error page?
      end
   end
  end

end
