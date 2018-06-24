# This class represents a generic option for something to do. For example, get
# drinks at Clinton Hall, or Go To The Natural History Museum. Some of these
# only happen once, some can be reused.

class Option < ApplicationRecord
  has_many :option_plans
  has_many :plans, through: :option_plans
  has_many :answers
end
