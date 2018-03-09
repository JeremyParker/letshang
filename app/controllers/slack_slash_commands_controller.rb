include Response
include SlackToken

# Handles all requests from Slack that come in the form of a slash command
class SlackSlashCommandsController < ApplicationController

  # POST /slack_slash_command
  def create
    puts request
    return json_response({}, status: 403) unless valid_slack_token?
    json_response({cool: 'cool'}, :created)
  end

end
