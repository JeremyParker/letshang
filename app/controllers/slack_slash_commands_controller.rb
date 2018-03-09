include Response
include SlackToken
require 'slack-ruby-client'

# Handles all requests from Slack that come in the form of a slash command
class SlackSlashCommandsController < ApplicationController

  # POST /slack_slash_command
  def create
    puts request
    return json_response({}, status: 403) unless valid_slack_token?
    json_response({cool: 'cool'}, :created)

    Slack.configure do |config|
      config.token = ENV['SLACK_APP_TOKEN']
      raise 'Missing ENV[SLACK_APP_TOKEN]!' unless config.token
    end

    client = Slack::Web::Client.new
    client.auth_test
    client.chat_postMessage(channel: '#general', text: 'Hello World', as_user: true)
  end
end
