module SlackSubmissionsHelper
  FALLBACK_MESSAGE = "Sorry, this bot isn't going to work on your system."

  # ask the user about what time they want to do this
  def self.rough_time_message(plan, channel_id)
    client = SlackHelper.set_up_client(plan.owner)
    client.chat_postEphemeral(
      channel: channel_id,
      user: plan.owner.slack_id,
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
  end

  # Ask the plan owner to enter an activity option
  def self.option_dialog(plan, trigger_id)
    client = SlackHelper.set_up_client(plan.owner)
    client.dialog_open(
      trigger_id: trigger_id,
      dialog: {
        "callback_id": "save_plan_option:#{plan.id}",
        "title": "Sugest an option",
        "submit_label": "OK",
        "elements": [
          {
            "type": "text",
            "label": "Title",
            "hint": "Provide a short label for this option, like \"Drinks at Moe's\"",
            "placeholder": "Title",
            "name": "option_title",
            "min_length": 1,
            "max_length": 64
          }
        ]
      }
    )
  end

  # tell the user their option was saved, and ask if they want to add another.
  def self.option_saved_message(plan, channel_id)
    callback_id = "after_option:#{plan.id}"
    if plan.options.count >= 8
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
          "text": "Would you like to give people another option?",
          "fallback": FALLBACK_MESSAGE,
          "attachment_type": "default",
          "actions": [
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
            },
            {
              "name": "response",
              "text": "Yes, Add Another",
              "type": "button",
              "value": "yes"
            }
          ]
        }
      ]
    end

    plan_list = plan.options.reduce("You've suggested these options:\n") do |msg, opt|
      msg + ":black_small_square: #{opt.title}\n"
    end
    client = SlackHelper.set_up_client(plan.owner)
    client.chat_postEphemeral(
      channel: channel_id,
      user: plan.owner.slack_id,
      text: "Great idea! That option is saved." + plan_list,
      attachments: attachments
    )
  end

  # send an invitation to a user to start their "receiver experience"
  def self.invitation(plan, user, trigger_id)
    date_string = plan.rough_time.today? ? 'today' : 'tomorrow'
    invitation_message = "TODO: use recipient's name and tag the Plan Owner: @owner wants to \
get a group of people together to do something #{date_string}. As long as at least \
#{plan.minimum_attendee_count} people can agree on something to do, we'll do it. You'll \
know the result wtihin two hours"
    client = SlackHelper.set_up_client(plan.owner)
    response = client.conversations_open(return_im: true, users: user.slack_id)
    channel_id = response[:channel][:id]
    callback_id = "invitation_availability:#{plan.id}:#{user.id}"
    client.chat_postMessage(
      channel: channel_id,
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
              "text": "Not this time :disappointed:",
              "type": "button",
              "value": "no"
            },
            {
              "name": "response",
              "text": "Maybe - what are the options?",
              "type": "button",
              "value": "yes"
            }
          ]
        }
      ]
    )
  end
end
