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
  #   "token"=>"xxxxxx_our_secret_token_xxxx",
  #   "response_url"=>"https://hooks.slack.com/app/T02CVNHRP/335745644371/ybOjTi2mV43CgnH4GVp1u9ox"
  # }
  def create
    payload = JSON.parse params[:payload]
    return json_response('', :forbidden) unless valid_slack_token? payload['token']

    case payload['type']

    when 'dialog_submission'
      case payload['callback_id']

      when /^set_plan_size/
        minimum_attendee_count = payload['submission']['plan_size'].to_i # TODO - error handling, bounds checking
        plan = Plan.includes(:owner).find(payload['callback_id'].split(':').last)
        plan.update(minimum_attendee_count: minimum_attendee_count)
        SlackSubmissionsHelper.rough_time_message(plan, payload['channel']['id'])
        json_response('', :ok)

      when /^save_plan_option/
        plan = Plan.includes(:owner).find(payload['callback_id'].split(':').last)
        title = payload['submission']['option_title']
        plan.options << Option.create(title: title)
        SlackSubmissionsHelper.option_saved_message(plan, payload['channel']['id'])
        json_response('', :ok)
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
    #   "token"=>"xxxxxx_our_secret_token_xxxx",
    #   "is_app_unfurl"=>false,
    #   "response_url"=>"https://hooks.slack.com/actions/T02CVNHRP/335796550691/WQOZmoeCQKZqxatQmSodkqcN",
    #   "trigger_id"=>"336718987558.2437765873.d037056e1569134854d268751706725a"
    # }
    when 'interactive_message'
      case payload['callback_id']
      when /^plan_time/
        plan = Plan.find(payload['callback_id'].split(':').last)
        input = payload['actions'][0]['selected_options'][0]['value']
        timezone = ActiveSupport::TimeZone.new(plan.timezone)
        Time.zone = timezone
        date = case input
        when 'today'
          timezone.today
        when 'tomorrow'
          timezone.tomorrow
        else
          json_response({text: "What? You plan too far in advance. Try being more spontaneous! Come back closer to when you want to go out."}, :created)
          return
        end
        plan.update(rough_time: date)

        # ask the user to suggest an activity option
        SlackSubmissionsHelper.new_option(plan, payload['trigger_id'])
        json_response('', :ok)

      # This is a response from the OptionNew "form" that we showed the Owner
      when /^option_new/
        plan = Plan.find(payload['callback_id'].split(':').last)
        timezone = ActiveSupport::TimeZone.new(plan.timezone)
        Time.zone = timezone
        if timezone.today > plan.rough_time
          json_response({text: "Woah there! The time of the gathering you're trying to organize is past!"}, :created)
          return
        end

        if payload['actions'][0]['value'] == 'yes'
          SlackSubmissionsHelper.new_option(plan, payload['trigger_id'])
        else
          # start a convo with all guests
          plan.invitations.each { |invitation| SlackSubmissionsHelper.invitation(plan, invitation.user, payload['trigger_id']) }
          plan.update(expiration: timezone.now + Plan::HOURS*06*60) # start the timer on when this Plan expires
          json_response({text: "OK. A personalized invitation has been sent to everyone you invited."}, :created)
        end

      when /^invitation_availability/ # callback_id looks like "invitation_availability:<plan_id>:<user_id>"
        plan_id = payload['callback_id'].split(':')[1]
        user_id = payload['callback_id'].split(':').last
        invitation = Invitation.where(user: user_id, plan: plan_id).last
        if payload['actions'][0]['value'] == 'yes'
          invitation.update(available: true)
          maybe_show_next_option(plan_id, user_id)
        else
          invitation.update(available: false)
          json_response({text: "OK, maybe we'll see you next time."}, :created)
        end

      # This is a response from when we showed a guest an option
      when /^show_option/ # show_option:#{option_plan.id}:#{user.id}
        option_plan_id = payload['callback_id'].split(':')[1]
        user_id = payload['callback_id'].split(':').last

        # TODO: plan_open_check - make sure their answer matters before recording it
        # TODO: prevent them from answering multiple times to the same option_plan

        # record the answer
        Answer.create(
          value: payload['actions'][0]['value'] == 'yes',
          user_id: user_id,
          option_plan_id: option_plan_id
        )
        option_plan = OptionPlan.find(option_plan_id)
        shown = maybe_show_next_option(option_plan.plan.id, user_id)
        if !shown && !evaluate(option_plan.plan)
          json_response({text: "OK. Within two hours we'll let you know if you have plans, and what you're doing."}, :created)
        end

      else
        json_response({text: "Uh oh! I don't know what callback that was for"}, :created)

      end
    else
      json_response({text: "Uh oh! Something went wrong. I'm sure someone will fix me soon."}, :created)
    end
  end

  private

  def maybe_show_next_option(plan_id, user_id)
    opts = OptionPlan.available_option_plans(plan_id, user_id)
    SlackSubmissionsHelper.show_option(opts.first, User.find(user_id)) if opts.present?
    opts.present? # return true if we showed them another option
  end

  # check the state of the plan and take appropriate action
  # This can be called from a cron job
  # @Return true if some action happened - like we sent out messages to folks, or something
  def evaluate(plan)
    case plan.poll
    when Plan::AGREED
      # Don't tell people who haven't responded yet. Too much noise. Wait for them to respond, then tell 'em.
      (plan.attendees << plan.owner).each { |user| SlackSubmissionsHelper.send_success_result(plan.winning_option_plan, user) }
      true
    when Plan::EXPIRED
      # Only tell people who said they were available. Too much noise otherwise. Wait for them to respond, then tell 'em.
      waiting_guests = Invitation.where(plan: plan).where(available: true).map(&:user).uniq
      (waiting_guests << plan.owner).each { |user| SlackSubmissionsHelper.send_failure_result(plan, user) }
      true
    when Plan::SUCCEEDED, Plan::FAILED, Plan::OPEN
      false
    end
  end

  # Check if the plan is still open. Call this on every response, so if someone is trying to
  # respond to a bunch of options at the moment that the plan is decided on, they don't have
  # to waste their time filling out the rest of the options.
  def plan_open_check
    true # TODO:
  end
end
