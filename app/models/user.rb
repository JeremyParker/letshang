# This model represents a human user of the system
# slack_id - the user's Slack ID
# team_id - the user's Team ID
# slack_user_name - the `name` field from Slack's UserInfo API (see #user_info in SlackHelper.rb)

class User < ApplicationRecord

  belongs_to :team

  has_many :plans # plans the user starts

  has_many :invitations
  has_many :plans, through: :invitations # plans the user is invited to

  has_many :attendances
  has_many :plans, through: :attendances # plans the user ends up attending
  has_many :responses

  def self.maybe_create(slack_user_id, slack_user_name, team)
    user = self.where(slack_id: slack_user_id).order(:updated_at).last
    user || team.users.create(slack_id: slack_user_id, slack_user_name: slack_user_name)
  end

end
