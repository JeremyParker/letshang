# An individual's answer to one option for a particular plan.

class Answer < ApplicationRecord
  belongs_to :option_plan
  belongs_to :user
end
