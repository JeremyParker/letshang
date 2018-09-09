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

  # This is the very beginning of the planning process.
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

  SUCCEEDED = 0 # Plan succeeded, people were notified. No action required.
  FAILED = 1    # Plan didn't succeed, people were notified. No action required.
  AGREED = 2    # Folks have agreed, haven't been notified yet
  EXPIRED = 3   # Expiration has passed, but haven't notified yet
  REJECTED = 4  # Too many people said no/unavailable, but haven't notified yet
  OPEN = 5      # Still working on it
  UNSENT = 6    # Never sent out to guests
  def status
    if succeeded
      SUCCEEDED
    elsif succeeded == false
      FAILED
    elsif agreed_option_plans.present?
      AGREED
    elsif !can_succeed?
      REJECTED
    elsif expired?
      EXPIRED
    elsif expiration
      OPEN
    else
      UNSENT
    end
  end

  def status_string
    %w(succeeded failed agreed expired rejected open unsent)[status]
  end


  # check the state of the plan and take appropriate action
  # This can be called from a cron job
  # @Return true if some action happened - like we sent out messages to folks, or something
  def evaluate
    case status
    when AGREED
      choose_winning_option_plan
      # Don't tell people who haven't responded yet. Too much noise. Wait for them to respond, then tell 'em.
      all_attendees = attendees << owner
      all_attendees.each do |user|
        guests = all_attendees.reject { |a| a == user }
        SlackSubmissionsHelper.send_success_result(winning_option_plan, user, guests)
      end
      update(succeeded: true)

      # inform guests who are available, but either haven't responded to the winning option yet, or said no to it.
      potential_extras = invitations.where(available: true).map(&:user).reject { |u| all_attendees.include?(u) }
      potential_extras.each { |u| SlackSubmissionsHelper.show_single_option(winning_option_plan, u, all_attendees) }
      true

    when EXPIRED, REJECTED
      # Only tell people who said they were available. Too much noise otherwise. Wait for them to respond, then tell 'em.
      waiting_guests = invitations.where(available: true).map(&:user).uniq
      (waiting_guests << owner).each { |user| SlackSubmissionsHelper.send_failure_result(self, user) }
      update(succeeded: false)
      true

    when SUCCEEDED, FAILED, OPEN
      false
    end
  end

  def choose_winning_option_plan
    # TODO: better winner selection logic than random
    self.update(winning_option_plan: agreed_option_plans.sample)
  end

  # Find the options for this plan that the minimum_attendee_count have agreed on.
  def agreed_option_plans
    answers = Answer.where(option_plan: option_plans).group_by(&:option_plan)
    option_plans.select { |op| answers[op] && answers[op].select(&:value).count >= minimum_attendee_count }
  end

  def start_timer
    update(expiration: Time.now + HOURS*60*60) # start the timer on when this Plan expires
  end

  def expired?
    Time.now > expiration if expiration
  end

  # is there any way this plan could succeed? I.e. have too many people said 'no'.
  def can_succeed?
    unavailable_count = invitations.where(:available => false).count
    option_plans.any? do |option_plan|
      invitations.count - (unavailable_count + option_plan.not_interested_count) >= minimum_attendee_count
    end
  end

  # who has responded 'yes' to the winning option_plan (NOTE: doesn't include Owner)
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
