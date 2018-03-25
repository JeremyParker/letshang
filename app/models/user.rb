class User < ApplicationRecord
  belongs_to :team

  has_many :plans # plans the user starts

  has_many :invitations
  has_many :plans, through: :invitations # plans the user is invited to

  has_many :attendances
  has_many :plans, through: :attendances # plans the user ends up attending

  def self.maybe_create(slack_user_id, team)
    user = self.where(slack_id: slack_user_id).order(:updated_at).last
    user || team.users.create(slack_id: slack_user_id)
  end

end
