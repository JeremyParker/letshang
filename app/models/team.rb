# A Model representing a Slack Team.

class Team < ApplicationRecord
  has_many :users

  def self.create_or_update(attributes)
    raise 'Missing team_id' unless attributes[:team_id]
    existing_team = self.where(team_id: attributes[:team_id]).order(:updated_at).last
    team = if existing_team
      existing_team.update_attributes(attributes)
      existing_team
    else
      self.create(attributes)
    end
    team
  end

  def to_s
    team_name
  end

end
