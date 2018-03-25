module SlackSlashCommandsHelper

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


INTRO = "Hi, I'm *Let's Hang*.
For info on how all this works, type `/letshang help`
To start planning an outing, tag your friends in a command like `/letshang @mike @taylor @susan`"

HELP_MESSAGE = "I’m here to help you get together with a group of friends on short notice. Here's how it works:
Tell me who to invite, when you want to get together, and the smallest group size you'd want to get together with. Then \
we'll put together a list of fun options you and your friends might want to do. I’ll find out who's free and what they're \
up for doing. If I can get enough people to agree on something to do within 2 hours, then *BOOM* your plans are made! I'll let \
everyone know what you're doing. If not, I'll let you know you still don't have plans.
To get started type `/letshang` followed by a list of your friends. For example ```/letshang @flavri @keely @marc @johannes \
@akbar @cl47 @dorothea @sonia @whoever @rbm```
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

  def self.start_plan(user_names)
    formatted_user_names = user_names[0..user_names.length - 2].map {|n| "@#{n}"}.join(', ') + ' and @' + user_names[user_names.length - 1]
    {
      text: "OK! We'll see if we can plan something with #{formatted_user_names}.",
      attachments: [
        {
          "text": "Sound good?",
          "fallback": "You are unable to create a plan",
          "callback_id": "start_plan_response",
          "color": "#3AA3E3",
          "attachment_type": "default",
          "actions": [
            {
              "name": "response",
              "text": "Yeah, let's go",
              "type": "button",
              "value": "yes"
            },
            {
              "name": "response",
              "text": "No. Let me try again.",
              "type": "button",
              "value": "no"
            }
          ]
        }
      ]
    }
  end
end
