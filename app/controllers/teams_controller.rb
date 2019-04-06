class TeamsController < ApplicationController
  before_action :authenticate_user_from_headers!
  before_action :check_admin!, except: [:index, :show]

  def index
    params[:page] ||= 1
    params[:per_page] ||= 20
    teams = Team.paginate(page: params[:page].to_i, per_page: params[:per_page].to_i)
    data = serialized_teams(teams)

    counter = Team.count # total_entries was problematic
    meta = {
      total: counter,
      per_page: params[:per_page].to_i,
      page: params[:page].to_i,
      page_count: counter.zero? ? 1 : (counter / params[:per_page].to_f).ceil
    }

    global_json_render(200, "Teams retrieved successfully", data, meta, true)
  end

  def show
    team = Team.find_by(id: params[:team_id])

    return global_json_render(200, "Team retrieved successfully", serialized_team(team)) if team
    global_error_render(404, "Team not found")
  end

  def create
    team = Team.new(name: params[:name])

    return global_json_render(201, "Team creation successful", serialized_team(team)) if team.save
    global_error_render(400, "Team creation unsuccessful", team.errors)
  end

  def update
    team = Team.find_by(id: params[:team_id])
    return global_error_render(404, "Team not found") unless team

    return global_error_render(400, "name must be provided") unless params[:name]

    return global_json_render(200, "Team updated successfully", serialized_team(team)) if team.update_attributes(name: params[:name])
    global_error_render(400, "Team could not be updated", team.errors)
  end

  def destroy
    team = Team.find_by(id: params[:team_id])
    return global_error_render(404, "Team not found") unless team

    return global_json_render(200, "Team deleted successfully", serialized_team(team)) if team.destroy
    global_error_render(400, "Team could not be deleted", team.errors)
  end

  def fixtures
    team = Team.find_by(id: params[:team_id])
    return global_error_render(404, "Team not found") unless team

    params[:page] ||= 1
    params[:per_page] ||= 20
    params[:fixtures] ||= 'all'

    if params[:fixtures] == 'all'
      fixtures = team.fixtures.paginate(page: params[:page].to_i, per_page: params[:per_page].to_i)
      counter = team.fixtures.count
    elsif params[:fixtures] == 'home'
      fixtures = team.home_fixtures.paginate(page: params[:page].to_i, per_page: params[:per_page].to_i)
      counter = team.home_fixtures.count
    elsif params[:fixtures] == 'away'
      fixtures = team.away_fixtures.paginate(page: params[:page].to_i, per_page: params[:per_page].to_i)
      counter = team.away_fixtures.count
    end

    meta = {
      total: counter,
      per_page: params[:per_page].to_i,
      page: params[:page].to_i,
      page_count: counter.zero? ? 1 : (counter / params[:per_page].to_f).ceil
    }
    
    data = Hash.new
    data['team'] = serialized_team(team)
    data['team']['fixtures'] = serialized_fixtures(fixtures)
    data['team']['meta'] = meta

    global_json_render(200, "Team fixtures retrieved successfully", data, {}, true)
  end

  private

  def serialized_team(team)
    data = TeamSerializer.new(team).serializable_hash
    data.dig(:data, :attributes)
  end

  def serialized_teams(teams)
    data = TeamSerializer.new(teams).serializable_hash
    data = data[:data].map do |team|
      team.dig(:attributes)
    end
    data
  end

  def serialized_fixtures(fixtures)
    data = FixtureSerializer.new(fixtures).serializable_hash
    data = data[:data].map do |fixture|
      fixture.dig(:attributes)
    end
    data
  end
end
