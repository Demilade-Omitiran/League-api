class Team < ApplicationRecord
  validates_presence_of :name
  validates_length_of :name, within: 4..30, too_long: 'Enter a shorter name', too_short: 'Enter a longer name', on: [:save, :update, :create]
  validates_uniqueness_of :name

  has_many :home_fixtures, class_name: "Fixture", foreign_key: "home_team_id"
  has_many :away_fixtures, class_name: "Fixture", foreign_key: "away_team_id"

  after_save :create_json_cache

  def fixtures
    Fixture.where('home_team_id=? OR away_team_id=?', self.id, self.id)
  end

  def self.search(team_name)
    team_name = team_name.capitalize if team_name
    return where('name LIKE ?', "%#{team_name}%") if team_name
    all
  end 

  def self.cache_key(teams)
    {
      serializer: 'teams',
      stat_record: teams.maximum(:updated_at)
    }
  end

  private

  def create_json_cache
    teams = Rails.cache.fetch('teams') do
      Team.paginate(page: 1, per_page: 20)
    end
  end
end
