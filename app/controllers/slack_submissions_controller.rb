include Response
include SlackToken

class SlackSubmissionsController < ApplicationController

  # POST /slack_submission
  def create
    # return json_response({}, status: 403) unless valid_slack_token_in_payload?

    # if params['payload'][:type] == 'interactive_message'
    #   if params['payload'][:callback_id] == 'create_plan'
    #     json_response('Yay! Starting a plan')
    #   end
    # end

    json_response("Great! I'll help you next week when my software is finished")
  end
end
