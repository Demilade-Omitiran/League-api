class Fixture < ApplicationRecord
  extend Enumerize

  belongs_to :home_team, :class_name => 'Team', :foreign_key => 'home_team_id'
  belongs_to :away_team, :class_name => 'Team', :foreign_key => 'away_team_id'

  validates_presence_of :home_team_id, :away_team_id, :match_date
  validate :check_home_and_away_teams
  validate :check_match_date, on: [:update, :create, :save]

  PERMITTED_STATUSES = %w[pending completed]

  enumerize :status, in: PERMITTED_STATUSES, predicates: true

  after_save :create_json_cache

  def check_home_and_away_teams
    errors.add(:away_team, "can't be the same as home_team") if home_team_id == away_team_id
  end

  def check_match_date
    # match_date = match_date + 1.hour #UTC problem

    if match_date.past?
      unless home_team_goals && away_team_goals
        errors.add(:match_date, "can't set match_date to a past date without both home_team_goals and away_team_goals")
      else
        self.status = 'completed'
      end

      
    end

    end_of_match = self.match_date + 110.minutes

    if (match_date.future? || (DateTime.now < end_of_match)) && home_team_goals && away_team_goals
      errors.add(:match_date, "cannot set home_team_goals and away_team_goals for a match set at a future date")
    end
  end

  def self.search(team_name = nil, team_fixtures = nil, status = nil, date_filter = nil, date = nil )
    if team_name && status && date_filter && date
      return filter_by_team(team_name, team_fixtures).where(status: status).filter_by_date(date_filter, date)
    elsif team_name && status
      return filter_by_team(team_name, team_fixtures).where(status: status)
    elsif team_name && date_filter && date
      return filter_by_team(team_name, team_fixtures).filter_by_date(date_filter, date)
    elsif status && date_filter && date
      return where(status: status).filter_by_date(date_filter, date)
    elsif team_name
      return filter_by_team(team_name, team_fixtures)
    elsif date_filter && date
      return filter_by_date(date_filter, date)
    elsif status
      return where(status: status)
    else
      all
    end
  end

  def self.cache_key(fixtures)
    {
      serializer: 'fixtures',
      stat_record: fixtures.maximum(:updated_at)
    }
  end

  private

  def self.filter_by_team(team_name, team_fixtures)
    team_name = team_name.capitalize
    return left_outer_joins(:home_team).where('teams.name LIKE ?', "%#{team_name}%") if team_fixtures == "home"
    return left_outer_joins(:away_team).where('teams.name LIKE ?', "%#{team_name}%") if team_fixtures == "away"

    if team_fixtures == nil || team_fixtures == 'all'
      home_fixtures = left_outer_joins(:home_team).where('teams.name LIKE ?', "%#{team_name}%")
      away_fixtures = left_outer_joins(:away_team).where('teams.name LIKE ?', "%#{team_name}%")
      
      home_array = home_fixtures.to_a
      away_array = away_fixtures.to_a

      total_arr = (home_array + away_array) - (home_array & away_array)
      where(id: total_arr.map(&:id))
    end
  end

  def self.filter_by_date(date_filter, date)
    case date_filter
    when "year"
      start_date, end_date = by_year(date)
    when "month"
      start_date, end_date = by_month(date)
    when "day"
      start_date, end_date = by_day(date)
    when "datetime"
      return where(match_date: date)
    end
    return where("match_date >= ? and match_date <= ?", start_date, end_date)
  end

  def self.by_year(date)
    year = date.to_i
    dt = DateTime.new(year)
    start_date = dt.beginning_of_year
    end_date = dt.end_of_year
    return start_date, end_date
  end

  def self.by_month(date)
    year = date.split("-")[0].to_i
    month = date.split("-")[1].to_i
    dt = DateTime.new(year, month)
    start_date = dt.beginning_of_month
    end_date = dt.end_of_month
    return start_date, end_date
  end

  def self.by_day(date)
    year = date.split("-")[0].to_i
    month = date.split("-")[1].to_i
    day = date.split("-")[2].to_i
    dt = DateTime.new(year, month, day)
    start_date = dt.beginning_of_day
    end_date = dt.end_of_day
    return start_date, end_date
  end
  
  def create_json_cache
    fixtures = Rails.cache.fetch('fixtures') do
      Fixture.paginate(page: 1, per_page: 20)
    end
  end
end
