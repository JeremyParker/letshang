module SlackHelper

  def self.set_up_client(user)
    Slack.configure do |config|
      config.token = user.team.bot_access_token
      config.logger = Rails::logger
    end
    Slack::Web::Client.new
  end

  def self.user_info(user)
    client = SlackHelper.set_up_client(user)
    users_info = client.users_info({ user: user.slack_id, include_locale: true })
    raise "Something went wrong" unless users_info[:ok]
    users_info[:user]
  end

end
