
module SlackToken
  def valid_slack_token?
    params[:token] == ENV["SLACK_APP_TOKEN"]
  end
end
