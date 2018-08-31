module SlackSlashCommandsHelper

INTRO = "Hi, I'm *Let's Hang*. For info on how all this works, type `/letshang help`"

HELP_MESSAGE = "---------------------------------
Hi, I'm *Let's Hang* :female_genie:.
I’m here to help you get together with a group of friends on short notice. Here's how it works:

:one: Type `/letshang` and tag all the people you want me to invite. For example `/letshang @taylor \
@amanda @mike @lauren @susan @mavreen @jabari @allegra @ayichew @vinaya @anfal @katya @krzysztof \
@margi` I'll guide you through the rest of the process.

:two: I'll ask you how big of a group you want to go out with. If I can get enough people to agree on \
something, then we'll do it. :grinning: If we can't reach your target group size, all bets are off. :disappointed:

:three: I'll ask roughly when you want to get together. :clock7:

:four: I'll help you put together a list of fun options you and your friends might want to do. :ballot_box_with_check:

From there I’ll take care of everything for you, and let you know the outcome!

I'll reach out to your friends and find out if they're free. I'll find out what activities they'd be up for doing. \
If I can get a big enough group to agree on something to do, then *BOOM* your plans are made! I'll message everyone \
and let them know what you're doing. If not enough people can agree, I'll let you all know you still don't have plans. \
All your guests' responses are confidential, and nobody knows who else is invited until a plan is made.
"
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
  def self.plan_size_message(plan, guests, channel_id, direct_message)
    client = SlackHelper.set_up_client(plan.owner)
    menu_items = (1..plan.invitations.count).map { |n| { "text": n.to_s, "value": n } }

    # pain in the ass: if it's a DM we have to create a conversation
    response = client.conversations_open(return_im: true, users: plan.owner.slack_id)
    channel_id = response[:channel][:id]

    client.chat_postEphemeral(
      channel: channel_id,
      user: plan.owner.slack_id,
      as_user: false,
      text: "Hey there! I'm here to help you make a plan with your friends. You've \
tagged #{format_user_names(guests.map(&:slack_id))}. If you want to cast a bigger net, now \
is a good time to start over. :arrows_counterclockwise:
How big of a group do you want to go out with? If I can get enough people to agree on \
something, then we'll do it. :grinning: If we can't reach your target group size, all bets are off. :disappointed:",
      attachments: [
        {
          "callback_id": "plan_size:#{plan.id}",
          "text": "What size group are we aiming for?",
          "actions": [
            {
              "name": "plan_size",
              "text": "Pick one",
              "type": "select",
              "options": menu_items
            }
          ]
        }
      ]
    )
  end
end
