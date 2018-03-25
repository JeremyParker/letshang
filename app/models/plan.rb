class Plan < ApplicationRecord
  belongs_to :owner, :class_name => :User, :foreign_key => "owner_id"

  has_many :invitations
  has_many :users, through: :invitations

  has_many :attendances
  has_many :users, through: :attendances

  has_many :option_plans
  has_many :options, through: :option_plans

  def self.start_plan(owner, invited_users)
    # create a plan record and add invitation records for these users
    new_plan = Plan.create(owner: owner)
    invited_users.each do |invited_user|
      new_plan.invitations << Invitation.create(user: invited_user)
    end
    new_plan
  end

end
