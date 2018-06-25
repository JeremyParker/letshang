# An individual's answer to one option for a particular plan.

# single_option:boolean - was this option offered as a single option? Usually
# because the plan was already decided on, and this guest is responding late or
# said 'no' initially.

class Answer < ApplicationRecord
  belongs_to :option_plan
  belongs_to :user
end
