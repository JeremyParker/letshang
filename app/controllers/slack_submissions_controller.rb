include Response
include SlackToken

class SlackSubmissionsController < ApplicationController
  protect_from_forgery :except => [:create] # we check the token 'manually' with `valid_slack_token`

  # POST /slack_submission
  # This method expects a payload from Slack like this:
  # {
  #   "type"=>"dialog_submission",
  #   "submission"=>{"plan_size"=>"2"},
  #   "callback_id"=>"set_plan_size:18",
  #   "team"=>{"id"=>"T02CVNHRP", "domain"=>"lollycom"},
  #   "user"=>{"id"=>"U02CVNHRR", "name"=>"jeremy"},
  #   "channel"=>{"id"=>"C9LPTG4E4", "name"=>"testing"},
  #   "action_ts"=>"1522019535.632639",
  #   "token"=>"<redacted>",
  #   "response_url"=>"https://hooks.slack.com/app/T02CVNHRP/335745644371/ybOjTi2mV43CgnH4GVp1u9ox"
  # }
  def create
    payload = JSON.parse params[:payload]
    return json_response({}, :forbidden) unless valid_slack_token? payload['token']

    case payload['type']

    when 'dialog_submission'
      case payload['callback_id']
      when /^set_plan_size/
        minimum_attendee_count = payload['submission']['plan_size'].to_i # TODO - error handling, bounds checking
        plan = Plan.find(payload['callback_id'].split(':').last)
        plan.update(minimum_attendee_count: minimum_attendee_count)

        Slack.configure do |config|
          config.token = plan.owner.team.bot_access_token
          config.logger = Rails::logger
        end
        client = Slack::Web::Client.new
        client.chat_postEphemeral(
          channel: payload['channel']['id'],
          user: payload['user']['id'],
          text: "",
          attachments: [
            {
              "callback_id": "plan_time:#{plan.id}",
              "attachment_type": "default",
              "color": "#3AA3E3",
              "text": "OK, we're planning an outing of at least #{minimum_attendee_count} people. When do you want this to happen?",
              "actions": [
                {
                  "name": "plan_time",
                  "text": "Pick one",
                  "type": "select",
                  "options": [
                    {
                        "text": "Tonight",
                        "value": "today"
                    },
                    {
                        "text": "Tomorrow",
                        "value": "tomorrow"
                    },
                    {
                        "text": "After tomorrow",
                        "value": "later"
                    }
                  ]
                }
              ]
            }
          ]
        )
        json_response({}, :ok)
    end

    # An interactive message expects the payload to look like
    # {
    #   "type"=>"interactive_message",
    #   "actions"=>[{"name"=>"plan_time", "type"=>"select", "selected_options"=>[{"value"=>"today"}]}],
    #   "callback_id"=>"plan_time:21",
    #   "team"=>{"id"=>"T02CVNHRP", "domain"=>"lollycom"},
    #   "channel"=>{"id"=>"C9LPTG4E4", "name"=>"testing"},
    #   "user"=>{"id"=>"U02CVNHRR", "name"=>"jeremy"},
    #   "action_ts"=>"1522035190.124049",
    #   "message_ts"=>"1522035178.000066",
    #   "attachment_id"=>"1",
    #   "token"=>"<redacted>",
    #   "is_app_unfurl"=>false,
    #   "response_url"=>"https://hooks.slack.com/actions/T02CVNHRP/335796550691/WQOZmoeCQKZqxatQmSodkqcN",
    #   "trigger_id"=>"336718987558.2437765873.d037056e1569134854d268751706725a"
    # }
    when 'interactive_message'
      case payload['callback_id']
      when /^plan_time/
        plan = Plan.find(payload['callback_id'].split(':').last)
        input = payload['actions'][0]['selected_options'][0]['value']
        date = case input
        when 'today'
          Date.today
        when 'tomorrow'
          Date.tomorrow
        else
          nil #TODO some error message and show them the dialog again
        end
        plan.update(rough_time: date)
        json_response({text: "Great. To add some options for people to do, enter `/letshang add`"}, :ok)
      else
        json_response("Uh oh! I don't know what callback that was for")
      end
    else
      json_response("Uh oh! Something went wrong. I'm sure someone will fix me soon.")
    end
  end
end
