include Response
include SlackToken

class SlackSubmissionsController < ApplicationController

  # POST /slack_submission
  def create
    puts request
    if params[:payload][:type] == 'interactive_message'
      if params[:payload][:callback_id] == 'create_plan'
        json_response('Yay! Starting a plan')
      end
    end

    json_response('Woah, something weird happened')
  end
end
