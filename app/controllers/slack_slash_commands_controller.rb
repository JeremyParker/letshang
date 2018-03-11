include Response
include SlackToken
require 'slack-ruby-client'

# Handles all requests from Slack that come in the form of a slash command
class SlackSlashCommandsController < ApplicationController

  INTRO_MESSAGE = "Hi there, I’m here to help you effortlessly plan a shindig! \
You pick the time, attendees, minimum number of people and 2-8 options of what \
you’d like to do. I’ll send the request and collect the votes. I can get the \
minimum number of people agree to on an option within 2 hours, I’ll create a \
group chat and announce the winning option. If a minimum number of attendees is \
not reached, I’ll cancel the request."

  # POST /slack_slash_command
  def create
    puts request
    return json_response({}, status: 403) unless valid_slack_token?
    json_response({
      "text": INTRO_MESSAGE,
      "attachments": [
        {
          "text": "Sound good?",
          "fallback": "You are unable to create a plan",
          "callback_id": "create_plan",
          "color": "#3AA3E3",
          "attachment_type": "default",
          "actions": [
            {
              "name": "response",
              "text": "Yeah, let's make a plan",
              "type": "button",
              "value": "yes"
            },
            {
              "name": "response",
              "text": "Nah, I'm good",
              "type": "button",
              "value": "no"
            }
          ]
        }
      ]
    }, :created)
  end
end
