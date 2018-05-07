# This is an instance of an Option that is being used in a Plan. This class
# will have the exact meeting time of this instance of the Option. If the
# Option is "See Black Panther at Alamo Drafthouse", the OptionPlan is "See
# Black Panther at Alamo Drafthouse on Tuesday, the 7:10pm Screening."

class OptionPlan < ApplicationRecord
  belongs_to :option
  belongs_to :plan
  has_many :answers

  # Fetch the OptionPlans for the given plan that the given user hasn't responded to yet.
  def self.available_option_plans(plan_id, user_id)
    # TODO: I'm sure this could be way more efficient
    option_plans = OptionPlan.includes(:option, :answers).where(plan: plan_id)
    option_plans.select { |op| op.answers.where(user: user_id).count == 0 }
  end

  def not_interested_count
    answers.where(:value => false).count
  end
end
