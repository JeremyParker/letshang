include Response
include SlackToken

class SlackSubmissionsController < ApplicationController

  TEST_DIALOG = {
    "callback_id": "ryde-46e2b0",
    "title": "Request a Ride",
    "submit_label": "Request",
    "elements": [
      {
        "type": "text",
        "label": "Pickup Location",
        "name": "loc_origin"
      },
      {
        "type": "text",
        "label": "Dropoff Location",
        "name": "loc_destination"
      }
    ]
  }

  # POST /slack_submission
  def create
    payload = JSON.parse params[:payload]
    return json_response({}, status: 403) unless valid_slack_token? payload['token']

    if payload['type'] == 'interactive_message'
      case payload['callback_id']
        when 'create_plan'
          team = Team.where(team_id: payload['team']['id']).order(:updated_at).last
          channel = payload['channel']['id']
          trigger_id = payload['trigger_id']

          # TODO: create a Plan object belonging to the initiating user

          Slack.configure do |config|
            config.token = team.bot_access_token
            config.logger = Rails::logger
          end
          client = Slack::Web::Client.new
          response =client.dialog_open(token: team.bot_access_token, dialog: TEST_DIALOG, trigger_id: trigger_id)

          json_response({}, :created)

          # response = client.conversations_open({return_im: true, users: user_id})
          # require 'pry'; binding.pry
          # client.chat_postMessage(
          #   channel: response[:channel][:id],
          #   text: "Thanks for installing Let's Hang!",
          #   as_user: false
          # )

          # # A response an include an interactive message with buttons
          # json_response({
          #   "text": 'Testing buttons in a response',
          #   "attachments": [
          #     {
          #       "text": "Sound good?",
          #       "fallback": "You are unable to create a plan",
          #       "callback_id": "create_plan",
          #       "color": "#3AA3E3",
          #       "attachment_type": "default",
          #       "actions": [
          #         {
          #           "name": "response",
          #           "text": "Yeah, let's make a plan",
          #           "type": "button",
          #           "value": "yes"
          #         },
          #         {
          #           "name": "response",
          #           "text": "Nah, I'm good",
          #           "type": "button",
          #           "value": "no"
          #         }
          #       ]
          #     }
          #   ]
          # }, :created)
      else
        json_response("Uh oh! I don't know what callback that was for")
      end
    else
      json_response("Uh oh! Something went wrong. I'm sure someone will fix me soon.")
    end
  end
end
