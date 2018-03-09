# Checks the incoming token passed wiht a request from Slack

module SlackToken
  def valid_slack_token?
    params[:token] == ENV["SLACK_APP_TOKEN"]
  end

  def valid_slack_token_in_payload?
    puts 'oooooo'
    puts params['payload'][:token]
    params['payload']['token']
    params['payload'][:token] == ENV["SLACK_APP_TOKEN"]
  end
end
