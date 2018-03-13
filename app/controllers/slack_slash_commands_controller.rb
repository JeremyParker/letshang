include Response
include SlackToken
include ParseUsers
include HelpMessage
include StartPlanMessage

# Handles all requests from Slack that come in the form of a slash command
class SlackSlashCommandsController < ApplicationController


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
    return json_response({}, status: 403) unless valid_slack_token?

    case params[:text]
    when ContainsUsers
      # TODO: create new user records for these users and a new plan.
      user_names = parse_user_names(params[:text])
      json_response(start_plan_message(user_names), :created)
    when /\A\s*\z|(help)/i # empty or the string 'help' (case insensitive)
      json_response(help_message, :created)
    else
      json_response({text: "Sorry, I didn't understand that"}, :created)
    end
  end
end
