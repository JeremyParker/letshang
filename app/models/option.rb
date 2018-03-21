class Option < ApplicationRecord
  has_many :option_plans
  has_many :plans, through: :option_plans
end
