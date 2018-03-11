include Response
include SlackToken

class SlackSubmissionsController < ApplicationController

  # POST /slack_submission
  def create
    payload = JSON.parse params[:payload]

    return json_response({}, status: 403) unless valid_slack_token? payload['token']

    if payload['type'] == 'interactive_message'
      case payload['callback_id']
        when 'create_plan'
          json_response('Yay! Starting a plan')
          Slack.configure do |config|
            config.token = ENV['SLACK_BOT_USER_TOKEN']
          end
          client = Slack::Web::Client.new
          client.auth_test
          client.chat_postMessage(channel: payload['channel']['id'], text: 'Hello World', as_user: false)
      else
        json_response("Oh oh! I don't know what callback that was for")
      end
    else
      json_response("Uh oh! Something went wrong. I'm sure someone will fix me soon.")
    end
  end
end
