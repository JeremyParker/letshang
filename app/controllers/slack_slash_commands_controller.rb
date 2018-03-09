include Response
include SlackToken
require 'slack-ruby-client'

# Handles all requests from Slack that come in the form of a slash command
class SlackSlashCommandsController < ApplicationController

  # POST /slack_slash_command
  def create
    puts request
    return json_response({}, status: 403) unless valid_slack_token?
    json_response({
      "text": "Would you like to play a game?",
      "attachments": [
        {
          "text": "Choose a game to play",
          "fallback": "You are unable to choose a game",
          "callback_id": "wopr_game",
          "color": "#3AA3E3",
          "attachment_type": "default",
          "actions": [
            {
              "name": "game",
              "text": "Chess",
              "type": "button",
              "value": "chess"
            },
            {
              "name": "game",
              "text": "Falken's Maze",
              "type": "button",
              "value": "maze"
            },
            {
              "name": "game",
              "text": "Thermonuclear War",
              "style": "danger",
              "type": "button",
              "value": "war",
              "confirm": {
                  "title": "Are you sure?",
                  "text": "Wouldn't you prefer a good game of chess?",
                  "ok_text": "Yes",
                  "dismiss_text": "No"
              }
            }
          ]
        }
      ]
    }, :created)

    # Slack.configure do |config|
    #   config.token = ENV['SLACK_BOT_USER_TOKEN']
    #   unless config.token
    #     Rails.logger.debug 'Missing ENV[SLACK_BOT_USER_TOKEN]!'
    #     raise 'Missing ENV[SLACK_BOT_USER_TOKEN]!'
    #   end
    # end

    # client = Slack::Web::Client.new
    # Rails.logger.debug client.auth_test
    # client.chat_postMessage(channel: params[:channel_id], text: 'Hello World', as_user: false)
  end
end
