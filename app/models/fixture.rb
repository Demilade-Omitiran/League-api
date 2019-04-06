class Fixture < ApplicationRecord
  extend Enumerize

  belongs_to :home_team, :class_name => 'Team', :foreign_key => 'home_team_id'
  belongs_to :away_team, :class_name => 'Team', :foreign_key => 'away_team_id'

  validates_presence_of :home_team_id, :away_team_id, :match_date
  validate :check_home_and_away_teams
  validate :check_match_date
  validate :check_status_before_update, on: :update

  PERMITTED_STATUSES = %w[pending completed]

  enumerize :status, in: PERMITTED_STATUSES, predicates: true
  
  def check_home_and_away_teams
    errors.add(:away_team_id, "can't be the same as home_team_id") if home_team_id == away_team_id
  end

  def check_match_date
    errors.add(:match_date, "can't be set for today; set it for a future date") if match_date.today?
    errors.add(:match_date, "can't be set for past date; set it for a future date") if match_date.to_date.past?
  end

  def check_status_before_update
    errors.add(:match_date, "can't edit the match_date of a completed fixture") if self.status == "completed"
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

  

  private

  def self.filter_by_team(team_name, team_fixtures)
    return left_outer_joins(:home_team).where('teams.name LIKE ?', "#{team_name}%") if team_fixtures == "home"
    return left_outer_joins(:away_team).where('teams.name LIKE ?', "#{team_name}%") if team_fixtures == "away"

    if team_fixtures == nil || team_fixtures == 'all'
      home_fixtures = left_outer_joins(:home_team).where('teams.name LIKE ?', "#{team_name}%")
      away_fixtures = left_outer_joins(:away_team).where('teams.name LIKE ?', "#{team_name}%")
      
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
end
