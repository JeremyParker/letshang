include Response
include SlackToken
include ParseUsers

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
      when /^save_plan_option/
        plan = Plan.includes(:owner).find(payload['callback_id'].split(':').last)
        title = payload['submission']['option_title']
        description  = payload['submission']['option_description']
        meeting_address  = payload['submission']['option_meeting_address']
        meeting_time  = payload['submission']['option_meeting_time']
        plan.options << Option.create(
          title: title,
          description: description,
          meeting_address:meeting_address,
          meeting_time: meeting_time,
          reusable: false
        )
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
       when /^plan_size/
        plan = Plan.includes(:owner).find(payload['callback_id'].split(':').last)
        input = payload['actions'][0]['selected_options'][0]['value'].to_i
        plan.update(minimum_attendee_count: input) # TODO - move this to plan.rb
        SlackSubmissionsHelper.rough_time_message(plan, payload['channel']['id'])
        json_response('', :ok)

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
          json_response('', :ok)
          return
        else
          # start a convo with all guests
          guests = plan.invitations.map(&:user)
          guests.each { |guest| SlackSubmissionsHelper.invitation(plan, guest, payload['trigger_id']) }
          plan.update(expiration: timezone.now + Plan::HOURS*06*60) # start the timer on when this Plan expires

          guest_names_string = format_user_names(guests.map(&:slack_id))
          json_response({text: "OK. A personalized invitation has been sent to #{guest_names_string}. I'll let you know the results within two hours!" }, :created)
        end

      when /^invitation_availability/ # callback_id looks like "invitation_availability:<plan_id>:<user_id>"
        plan_id = payload['callback_id'].split(':')[1]
        user_id = payload['callback_id'].split(':').last
        invitation = Invitation.where(user: user_id, plan: plan_id).last
        plan = Plan.find(plan_id)
        user = User.find(user_id)
        if payload['actions'][0]['value'] == 'yes'
          invitation.update(available: true)
          if plan.status == Plan::SUCCEEDED
            # if the plan is already decided on, just ask about the one winning option
            SlackSubmissionsHelper.show_single_option(plan.winning_option_plan, user, plan.attendees + [plan.owner])
          else
            next_guest_step(plan_id, user_id)
          end
        else
          invitation.update(available: false)
          plan.evaluate
          SlackSubmissionsHelper.show_goodbye(plan, user)
        end
        json_response('', :created)

      # This is a response from when we showed a guest an option
      when /^show_option/ # show_option:#{option_plan.id}:#{user.id}
        handle_option_response(payload)

      # this is a response from a guest who either said 'no' to the winning option, or reponded late.
      when /^show_single_option/ # show_single_option:#{option_plan.id}:#{user.id}
        handle_option_response(payload, true)

      else
        json_response({text: "Uh oh! I don't know what callback that was for"}, :created)

      end
    else
      json_response({text: "Uh oh! Something went wrong. I'm sure someone will fix me soon."}, :created)
    end
  end

  private

  # A guest has resopnded to one of the options. Depending on the state of the plan, this might be
  # the only option they were offered.
  def handle_option_response(payload, single_option = false)
    option_plan_id = payload['callback_id'].split(':')[1]
    user_id = payload['callback_id'].split(':').last
    # TODO: prevent them from answering multiple times to the same option_plan
    # record the answer
    Answer.create(
      value: payload['actions'][0]['value'] == 'yes',
      user_id: user_id,
      option_plan_id: option_plan_id,
      single_option: single_option
    )
    option_plan = OptionPlan.find(option_plan_id)
    next_guest_step(option_plan.plan_id, user_id)
    json_response('', :created)
  end

  # Take the next step for this plan for this guest.
  # Maybe show them another option.
  # Maybe tell them the plan failed already
  # Maybe tell them it'd been decided, and there's only one option now.
  def next_guest_step(plan_id, user_id)
    plan = Plan.find(plan_id)
    user = User.find(user_id)

    puts "**** plan status is #{plan.status}"
    case plan.status
    when Plan::SUCCEEDED
      # check if this user has a single_option_answer (i.e. we asked after the plan SUCCEEDED)
      single_option_answer = user.answers.where(option_plan_id: plan.winning_option_plan_id, single_option: true).first
      if single_option_answer
        # If so, and it was 'yes', then let everyone know this person is joining them
        if single_option_answer.value
          already_attending = plan.attendees.reject { |a| a.id == user.id } + [plan.owner]
          already_attending.each { |a| SlackSubmissionsHelper.send_new_attendee_notification(plan, a, user) }
        else
          # if they answered 'no', then say "see ya!"
          SlackSubmissionsHelper.show_goodbye(plan, user)
        end
      end
    when Plan::FAILED, Plan::REJECTED, Plan::EXPIRED
      SlackSubmissionsHelper.send_failure_result(plan, user)
    when Plan::OPEN, Plan::AGREED
      shown = maybe_show_next_option(plan, user)
      if !shown && !plan.evaluate
        json_response({text: "OK. Within two hours we'll let you know if you have plans, and what you're doing."}, :created)
      end
    end
  end

  def maybe_show_next_option(plan, user)
    opts = OptionPlan.available_option_plans(plan.id, user.id)
    SlackSubmissionsHelper.show_option(opts.sample, user) if opts.present?
    opts.present? # return true if we showed them another option
  end

  # Check if the plan is still open. Call this on every response, so if someone is trying to
  # respond to a bunch of options at the moment that the plan is decided on, they don't have
  # to waste their time filling out the rest of the options.
  def plan_open?(plan)
    plan.status == Plan::OPEN
  end

end
