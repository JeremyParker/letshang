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
  #   "user_name"=>"Lauren", (same as `user_info[:name]`)
  #   "command"=>"/letshang",
  #   "text"=>"",
  #   "response_url"=>"https://hooks.slack.com/commands/T02CVNHRP/327417106544/iM9ViW4HVADaiU2zd9iSvEqX",
  #   "trigger_id"=>"329123764679.2437765873.fb7a514ebcd5c244e221807f8de8f231",
  #   "controller"=>"slack_slash_commands",
  #   "action"=>"create"
  # }
  def create
    return json_response({}, :forbidden) unless valid_slack_token?

    case params[:text]

    when ContainsUsers # when the slash command has users tagged in it
      user_names = parse_user_names(params[:text])
      return json_response(SlackSlashCommandsHelper.start_plan_more_people, :created) if user_names.length < 2
      team = Team.where(team_id: params[:team_id]).order(:updated_at).last
      # get an array of [id, name] pairs
      user_id_name_array = parse_user_ids(params[:text]).zip(parse_user_names(params[:text])).uniq{ |u| u[0] }
      guests = user_id_name_array.map { |user_id_name| User.maybe_create(user_id_name[0], user_id_name[1], team) }

      initiating_user = User.maybe_create(params[:user_id], params[:user_name], team)
      users_info = SlackHelper.user_info(initiating_user)
      plan = Plan.start_plan(initiating_user, guests, users_info[:tz])
      direct_message = (params[:channel_name] == "directmessage")
      SlackSlashCommandsHelper.plan_size_message(plan, guests, params[:channel_id], direct_message)

    when /help$/i # the string 'help' (case insensitive)
      json_response(SlackSlashCommandsHelper.help(), :created)

    when /\A\s*\z/ # empty
      json_response(SlackSlashCommandsHelper.intro(), :created)

    else
      json_response({text: "Sorry, I didn't understand that"}, :created)
    end
  end
end
