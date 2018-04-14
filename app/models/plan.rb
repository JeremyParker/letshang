class Plan < ApplicationRecord
  belongs_to :owner, :class_name => :User, :foreign_key => "owner_id"

  has_many :invitations
  has_many :users, through: :invitations

  has_many :attendances
  has_many :users, through: :attendances

  has_many :option_plans
  has_many :options, through: :option_plans

  # create a plan record and add invitation records for these users
  # @param owner - User object
  # @param invited_users - Array of User objects for who's invited
  # @tz_offset - Integer for seconds offset from UTC for this plans
  # @timezone_name - String with the name of the timezone for this plan
  def self.start_plan(owner, invited_users, tz_offset, timezone)
    new_plan = Plan.create(owner: owner, tz_offset: tz_offset, timezone: timezone)
    invited_users.each do |invited_user|
      new_plan.invitations << Invitation.create(user: invited_user)
    end
    new_plan
  end

end
