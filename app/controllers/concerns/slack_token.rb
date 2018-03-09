# Checks the incoming token passed wiht a request from Slack

module SlackToken
  def valid_slack_token?
    params[:token] == ENV["SLACK_APP_TOKEN"]
  end
end
