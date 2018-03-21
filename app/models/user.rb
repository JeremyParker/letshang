class User < ApplicationRecord
  belongs_to :team

  has_many :invitations
  has_many :plans, through: :invitations

  has_many :attendances
  has_many :plans, through: :attendances
end
