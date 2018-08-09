module SlackSlashCommandsHelper

INTRO = "Hi, I'm *Let's Hang*. For info on how all this works, type `/letshang help`"

HELP_MESSAGE = "I’m here to help you get together with a group of friends on short notice. Here's how it works:
Tell me who to invite. Tell me how many of them you want to gather in order for it to be a fun outing. And tell \
me when you want to get together. Then I'll help you put together a list of fun options you and your friends might \
want to do. I’ll find out who's free and what they're up for doing. If I can get enough people to agree on something \
to do within 2 hours, then *BOOM* your plans are made! I'll let everyone know what you're doing. If not, I'll let you \
know you still don't have plans.
To get started type `/letshang` followed by a list of your friends. For example ```/letshang @amanda @mike @taylor @susan```
The more people you invite, the more likely you'll have a plan!"

  def self.intro
    { text: INTRO }
  end

  def self.help
    { text: HELP_MESSAGE }
  end

  def self.start_plan_more_people
    { text: "If you only want to invite one other person, you don't need my help. Just DM them!"}
  end

  # ask the owner what size group they'd be happy with
  def self.plan_size_message(plan, guests, channel_id)
    client = SlackHelper.set_up_client(plan.owner)
    options = (1..plan.invitations.count).map { |n| { "text": n.to_s, "value": n } }
    client.chat_postEphemeral(
      channel: channel_id,
      user: plan.owner.slack_id,
      text: "OK great. We'll check with #{format_user_names(guests.map(&:slack_id))} and see who's around.",
      attachments: [
        {
          "callback_id": "plan_size:#{plan.id}",
          "text": "What's the smallest group of these people you'd want to get together with?",
          "actions": [
            {
              "name": "plan_size",
              "text": "Pick one",
              "type": "select",
              "options": options
            }
          ]
        }
      ]
    )
  end
end
