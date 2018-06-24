module SlackHelper

  def self.set_up_client(user)
    Slack.configure do |config|
      config.token = user.team.bot_access_token
      config.logger = Rails::logger
    end
    Slack::Web::Client.new
  end

  # returns a hash with user's info. Here's what I think we've figured out about this hash.
  # [name] is what we get in the text field of a slash command like <@U02CWFEEJ|my_name>. I
  #    think it's the first part of what the user entered for their email address?
  # [real_name] and [profile][real_name] are what the user entered for FirstName and LastName combined
  # [profile][display_name] is what users see in Slack when they tag someone. E.g. @taylor
  def self.user_info(user)
    client = SlackHelper.set_up_client(user)
    users_info = client.users_info({ user: user.slack_id, include_locale: true })
    raise "Something went wrong" unless users_info[:ok]
    users_info[:user]
  end

end
