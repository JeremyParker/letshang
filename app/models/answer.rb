class Answer < ApplicationRecord
  belongs_to :option_plan
  belongs_to :user
end
