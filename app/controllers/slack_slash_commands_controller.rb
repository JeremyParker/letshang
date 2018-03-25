include Response
include SlackToken
include ParseUsers

# Handles all requests from Slack that come in the form of a slash command
class SlackSlashCommandsController < ApplicationController
  protect_from_forgery :except => [:create] # we check the token 'manually' with `valid_slack_token`

  # POST /slack_slash_command
  # We expect params to look like this:
  # {
  #   "token"=>"xxxxxx_our_secret_token_xxxx",
  #   "team_id"=>"TXXXXXX",
  #   "team_domain"=>"some_team_domain",
  #   "channel_id"=>"CXXXXXX",
  #   "channel_name"=>"some_channel_name",
  #   "user_id"=>"UXXXXXXX",
  #   "user_name"=>"my name",
  #   "command"=>"/letshang",
  #   "text"=>"",
  #   "response_url"=>"https://hooks.slack.com/commands/T02CVNHRP/327417106544/iM9ViW4HVADaiU2zd9iSvEqX",
  #   "trigger_id"=>"329123764679.2437765873.fb7a514ebcd5c244e221807f8de8f231",
  #   "controller"=>"slack_slash_commands",
  #   "action"=>"create"
  # }
  def create
    puts request
    return json_response({}, :forbidden) unless valid_slack_token?

    case params[:text]
    when ContainsUsers #when the slash command has users tagged in it
      user_names = parse_user_names(params[:text])
      return json_response(SlackSlashCommandsHelper.start_plan_more_people, :created) if user_names.length < 2

      json_response(SlackSlashCommandsHelper.start_plan(user_names), :created)

      # TODO: create new user records for these users and a new plan.
      user_ids = parse_user_ids(params[:text])

      # TESTING ##################################################
      # team = Team.where(team_id: params['team_id']).order(:updated_at).last

      # Slack.configure do |config|
      #   config.token = team.bot_access_token
      #   config.logger = Rails::logger
      # end
      # client = Slack::Web::Client.new
      # comma_separated_users = user_ids.join(',')
      # response = client.conversations_open(token: team.bot_access_token, return_im: true, users: comma_separated_users)
      # client.chat_postMessage(text: 'whassup!', channel: response[:channel][:id])
      ############################################################

    when /help$/i # the string 'help' (case insensitive)
      json_response(SlackSlashCommandsHelper.help(), :created)
    when /\A\s*\z/ # empty
      json_response(SlackSlashCommandsHelper.intro(), :created)
    else
      json_response({text: "Sorry, I didn't understand that"}, :created)
    end
  end
end
