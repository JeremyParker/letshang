class Response < ApplicationRecord
  belongs_to :user
  belongs_to :option_plan
end
