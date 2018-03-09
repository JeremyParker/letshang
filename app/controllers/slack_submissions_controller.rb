include Response
include SlackToken

class SlackSubmissionsController < ApplicationController

  # POST /slack_submission
  def create
    puts request

    json_response({cool: 'cool'}, :created)
  end
end
