module HelpMessage

HELP_MESSAGE = "Hi, I’m here to help you get together with a group of friends on short notice. Here's how it works:
Tell me when you want to get together, who to invite, and the smallest group size you'd want to get together with. Then \
give me a list of things you'd consider doing. I’ll find out who's free and what they're up for. If I can get enough \
people to agree on something to do within 2 hours, then I'll let everyone know what the plan is. If not, you can try again.
To get started type `/letshang` followed by a list of your friends. For example ```/letshang @flavri @keely @marc @johannes \
@akbar @cl47 @dorothea @sonia @whoever @rbm```
The more people you invite, the more likely you'll have a plan!"

  def help_message
    { text: HELP_MESSAGE }
  end
end
