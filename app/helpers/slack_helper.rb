module SlackHelper

  def self.set_up_client(user)
    Slack.configure do |config|
      config.token = user.team.bot_access_token
      config.logger = Rails::logger
    end
    Slack::Web::Client.new
  end

end