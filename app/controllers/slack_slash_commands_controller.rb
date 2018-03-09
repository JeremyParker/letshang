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
      config.token = ENV['SLACK_BOT_USER_TOKEN']
      unless config.token
        Rails.logger.debug 'Missing ENV[SLACK_BOT_USER_TOKEN]!'
        raise 'Missing ENV[SLACK_BOT_USER_TOKEN]!'
      end
    end

    client = Slack::Web::Client.new
    Rails.logger.debug client.auth_test
    client.chat_postMessage(channel: '#general', text: 'Hello World', as_user: true)
  end
end
