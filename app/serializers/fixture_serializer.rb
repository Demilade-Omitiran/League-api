class FixtureSerializer
  include FastJsonapi::ObjectSerializer
  attributes :id

  attribute :home_team do |object|
    home_team = Team.find(object.home_team_id).name
  end

  attribute :away_team do |object|
    away_team = Team.find(object.away_team_id).name
  end

  attributes :home_team_goals, :away_team_goals, :match_date, :status, :created_at, :updated_at

end
