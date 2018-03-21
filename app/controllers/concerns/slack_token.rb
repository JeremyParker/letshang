# Checks the incoming token passed wiht a request from Slack

module SlackToken
  def valid_slack_token?(token=nil)
    token ||= params[:token]
    token == ENV["SLACK_VERIFICATION_TOKEN"]
  end
end
