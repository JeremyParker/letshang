include Response
include SlackToken

class SlackSubmissionsController < ApplicationController

  # POST /slack_submission
  def create
    puts request
    return json_response({}, status: 403) unless valid_slack_token?
    json_response({cool: 'cool'}, :created)
  end
end
