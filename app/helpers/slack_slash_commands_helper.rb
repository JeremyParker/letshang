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
Tell me who to invite. Tell me how many of them you want to gather in order for it to be a fun outing. And tell \
me when you want to get together. Then I'll help you put together a list of fun options you and your friends might \
want to do. I’ll find out who's free and what they're up for doing. If I can get enough people to agree on something \
to do within 2 hours, then *BOOM* your plans are made! I'll let everyone know what you're doing. If not, I'll let you \
know you still don't have plans.
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

  def self.plan_size_dialog(plan, trigger_id)
    dialog = {
      "callback_id": "set_plan_size:#{plan.id}",
      "title": "Smallest Group That's OK",
      "submit_label": "OK",
      "elements": [
        {
          "type": "text",
          "subtype": "number",
          "label": "Minimum Group Size",
          "hint": "What's the smallest number of people you'd want to get together with? Enter a number between 2 and #{plan.invitations.count + 1}. The more the merrier!",
          "placeholder": "Enter a number",
          "name": "plan_size",
          "min_length": 1,
          "max_length": 3
        }
      ]
    }
    bot_access_token = plan.owner.team.bot_access_token
    Slack.configure do |config|
      config.token = bot_access_token
      config.logger = Rails::logger
    end
    client = Slack::Web::Client.new
    client.dialog_open(token: bot_access_token, dialog: dialog, trigger_id: trigger_id)
  end

end
