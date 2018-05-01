# Model for a plan: a set of outing ideas that may or may not be agreed upon.
# minimum_attendee_count [Integer] - people count EXCLUDING the organizer who have to agree.

class Plan < ApplicationRecord
  belongs_to :owner, :class_name => :User, :foreign_key => "owner_id"
  belongs_to :winning_option_plan, :class_name => :OptionPlan, :foreign_key => "winning_option_plan_id", optional: true

  has_many :invitations
  has_many :users, through: :invitations

  has_many :attendances
  has_many :users, through: :attendances

  has_many :option_plans
  has_many :options, through: :option_plans

  HOURS = 2 # How long do the users have before the plan expires?

  # create a plan record and add invitation records for these users
  # @param owner - User object
  # @param invited_users - Array of User objects for who's invited
  # @timezone_name - String with the name of the timezone for this plan
  def self.start_plan(owner, invited_users, timezone)
    new_plan = Plan.create(owner: owner, timezone: timezone)
    invited_users.each do |invited_user|
      new_plan.invitations << Invitation.create(user: invited_user)
    end
    new_plan
  end

  # This is the method that should get called on all open plans (plan.succeeded == NULL)
  # Updates the state of the plan, and returns the result
  SUCCEEDED = 0 # Plan succeeded, people were notified. No action required.
  FAILED = 1    # Plan didn't succeed, people were notified. No action required.
  AGREED = 2    # Folks have agreed, haven't been notified yet (only gets returned once)
  EXPIRED = 3   # Expiration has passed, but haven't notified yet (only gets returned once)
  OPEN = 4      # Still working on it
  # TODO - make a status for "logically can't be agreed on. See `can_succeed`"
  def poll
    if succeeded
      SUCCEEDED
    elsif succeeded == false
      FAILED
    elsif expired?
      self.update(succeeded: false)
      EXPIRED
    elsif agreed_option_plans.present?
      # TODO: better winner selection logic than random
      self.update(winning_option_plan: agreed_option_plans.sample, succeeded: true)
      AGREED
    else
      OPEN
    end
  end

  # Find the options for this plan that the minimum_attendee_count have agreed on.
  def agreed_option_plans
    answers = Answer.where(option_plan: option_plans).group_by(&:option_plan)
    option_plans.select { |op| answers[op].select(&:value).count >= minimum_attendee_count }
  end

  def expired?
    ActiveSupport::TimeZone.new(timezone).now > expiration if expiration
  end

  # is there any way this plan could succeed? I.e. have too many people said 'no', or has it timed out?
  def can_succeed
    # TODO
  end

  # who has responded 'yes' to the winning option_plan
  def attendees
    # NOTE: late responders who tag along will have a 'yes' response added for the winning option_plan
    if winning_option_plan
      Answer.where(option_plan: winning_option_plan, value: true).map(&:user).uniq
    else
      []
    end
  end

  def formatted_rough_time
    rough_time.today? ? 'tonight' : 'tomorrow night'
  end
end
