include ParseUsers

module SlackSubmissionsHelper
  FALLBACK_MESSAGE = "Sorry, this bot isn't going to work on your system."

  # ask the user about what time they want to do this
  def self.rough_time_message(plan, channel_id)
    {
      text: "",
      attachments: [
        {
          "callback_id": "plan_time:#{plan.id}",
          "text": "OK, we're planning an outing of at least #{plan.minimum_attendee_count} other people. When do you want this to happen?",
          "actions": [
            {
              "name": "plan_time",
              "text": "Pick one",
              "type": "select",
              "options": [
                {
                    "text": "Today/Tonight",
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
    }
  end

  # Ask the plan owner to enter an activity option
  def self.new_option_dialog(plan, trigger_id)
    client = SlackHelper.set_up_client(plan.owner)
    client.dialog_open(
      trigger_id: trigger_id,
      dialog: {
        "callback_id": "save_plan_option:#{plan.id}",
        "title": "Suggest an option",
        "submit_label": "OK",
        "elements": [
          {
            "type": "text",
            "label": "Activity",
            "hint": "Provide a short label for this option, like \"Drinks at Moe's\"",
            "placeholder": "Activity",
            "name": "option_title",
            "min_length": 1,
            "max_length": 64
          },
          {
            "type": "textarea",
            "label": "Description",
            "optional": true,
            "hint": "More information about this activity, maybe a URL with details... whatever.",
            "placeholder": "More details if necessary",
            "name": "option_description",
            "max_length": 400
          },
          {
            "type": "text",
            "label": "Exact Meeting Address",
            "optional": true,
            "hint": "A street address where we'll meet, like \"720 Evergreen Terrace, Sringfield \"",
            "placeholder": "Address",
            "name": "option_meeting_address",
            "min_length": 0,
            "max_length": 150
          },
          {
            "type": "text",
            "label": "Exact Meeting Time",
            "hint": "What time will we meet there? Like \"7:30pm\"",
            "placeholder": "Meeting Time",
            "name": "option_meeting_time",
            "min_length": 1,
            "max_length": 8
          }
        ]
      }
    )
  end

  # tell the user their option was saved, and ask if they want to add another.
  def self.option_saved_message(plan, channel_id)
    callback_id = "option_new:#{plan.id}"
    if plan.options.count > 6
      attachments = [
        {
          "callback_id": callback_id,
          "text": ":open_mouth: Wow, that's a lot of options options for people to choose from!",
          "attachment_type": "default",
          "actions": [
            {
              "name": "response",
              "text": "OK, let's move on",
              "type": "button",
              "value": "no"
            }
          ]
        }
      ]
    else
      attachments = [
        {
          "callback_id": callback_id,
          "text": "Would you like to give your guests another option to choose from?",
          "fallback": FALLBACK_MESSAGE,
          "attachment_type": "default",
          "actions": [
            {
              "name": "response",
              "text": "Yes, Add Another",
              "type": "button",
              "value": "yes"
            },
            {
              "name": "response",
              "text": "No, That's Enough",
              "type": "button",
              "value": "no",
              "confirm": {
                "title": "Are you sure?",
                "text": "The more options you suggest, the more likely you'll have plans!",
                "dismiss_text": "Keep Adding Options",
                "ok_text": "That's Enough"
              }
            }
          ]
        }
      ]
    end

    plan_list = plan.options.reduce("You have these options so far:\n") do |msg, opt|
      msg + ":black_small_square: #{opt.title}\n"
    end
    client = SlackHelper.set_up_client(plan.owner)
    client.chat_postEphemeral(
      channel: channel_id,
      user: plan.owner.slack_id,
      text: "Great idea! That option is saved.\n" + plan_list,
      attachments: attachments
    )
  end

  # send an invitation to a user to start their "receiver experience".
  def self.invitation(plan, user, trigger_id)
    invitation_message = "Hi #{user.slack_user_name}! <@#{plan.owner.slack_id}> wants to \
get a group of people together to do something #{plan.formatted_rough_time}. As long as at least \
#{plan.minimum_attendee_count + 1} of us can agree on something to do, we'll do it. You'll \
know the result within two hours."
    client = SlackHelper.set_up_client(plan.owner)
    response = client.conversations_open(return_im: true, users: user.slack_id)
    channel_id = response[:channel][:id]
    callback_id = "invitation_availability:#{plan.id}:#{user.id}"
    response = client.chat_postMessage(
      channel: channel_id,
      user: user.slack_id,
      text: invitation_message,
      attachments: [
        {
          "callback_id": callback_id,
          "text": "Are you in?",
          "fallback": FALLBACK_MESSAGE,
          "attachment_type": "default",
          "actions": [
            {
              "name": "response",
              "text": "Maybe - what are the options?",
              "type": "button",
              "value": "yes"
            },
            {
              "name": "response",
              "text": "Not this time :disappointed:",
              "type": "button",
              "value": "no"
            }
          ]
        }
      ]
    )
    puts "message sent to #{user.slack_id}. Response:\n" + response.to_s
  end

  # show a goodbye message
  def self.show_goodbye(option_plan, user)
    {
      text: "OK, :disappointed: maybe we'll see you next time."
    }
  end

  # show one of the event options to a guest
  def self.show_option(option_plan, user)
    callback_id = "show_option:#{option_plan.id}:#{user.id}"
    {
      text: 'How about doing this?',
      attachments: self.format_option_attachments(option_plan, callback_id)
    }
  end

  # When a plan is already decided on, a late-responder or no-voter might want to join.
  def self.show_single_option(option_plan, user, guests)
    callback_id = "show_single_option:#{option_plan.id}:#{user.id}"
    {
      text: "A decision has been made! :smile: You haven't said you wanted to do it, but it's not \
too late to join the fun. Would you like to join #{format_user_names(guests.map(&:slack_id))} \
doing this:",
      attachments: self.format_option_attachments(option_plan, callback_id)
    }
  end

  # send the successful result to a user (guest or owner)
  def self.send_success_result(option_plan, user, guests)
    client = SlackHelper.set_up_client(user)
    response = client.conversations_open(return_im: true, users: user.slack_id)
    channel_id = response[:channel][:id]
    # chat_postMessage not chat_postEphemeral, so it sticks around for later reference.
    client.chat_postMessage(
      channel: channel_id,
      text: "Congrats! You have plans! #{format_user_names(guests.map(&:slack_id))} are going to join you to do this:",
      attachments: format_option_attachments(option_plan, nil)
    )
  end

  # send a failure message to a user (guest or owner)
  def self.send_failure_result(plan, user)
    client = SlackHelper.set_up_client(user)
    response = client.conversations_open(return_im: true, users: user.slack_id)
    channel_id = response[:channel][:id]
    client.chat_postMessage(
      channel: channel_id,
      text: "Sorry, people couldn't agree on a plan for #{plan.formatted_rough_time}. The good news is you can try again!",
    )
  end

  # notify a user (guest or owner) that a new guest is attending
  def self.send_new_attendee_notification(plan, user, new_attendee)
    client = SlackHelper.set_up_client(user)
    response = client.conversations_open(return_im: true, users: user.slack_id)
    channel_id = response[:channel][:id]
    client.chat_postMessage(
      channel: channel_id,
      text: "Good news! <@#{new_attendee.slack_id}> has decided to join you #{plan.formatted_rough_time} \
for your outing, #{plan.winning_option_plan.option.title}!"
    )
  end

private

  def self.format_option_attachments(option_plan, callback_id = nil)
    result = {
      "callback_id": callback_id,
      "color": "#36a64f",
      "title": option_plan.option.title,
      "text": option_plan.option.description,
      "fields": [
        {
          "title": "Meet At",
          "value": "#{option_plan.option.meeting_address}, #{option_plan.option.meeting_time}",
          "short": false
        }
      ],
      "fallback": FALLBACK_MESSAGE,
      "attachment_type": "default"
    }

    if callback_id
      result.merge!("actions": [
        {
          "name": "response",
          "text": "I'd do that",
          "type": "button",
          "value": "yes"
        },
        {
          "name": "response",
          "text": "No thanks",
          "type": "button",
          "value": "no"
        }
      ])
    end
    [result]
  end

end
