class TeamsController < ApplicationController
  before_action :authenticate_user_from_headers!
  before_action :check_admin!, except: [:index, :show]

  def index
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    teams = Team.paginate(page: page, per_page: per_page)
    data = serialized_teams(teams)

    counter = teams.total_entries
    meta = {
      total: counter,
      per_page: per_page.to_i,
      page: page.to_i,
      page_count: counter.zero? ? 1 : (counter / per_page.to_f).ceil
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

    return global_json_render(200, "Team updated successfully", serialized_team(team)) if team.update_attribute(:name, params[:name])
    global_error_render(400, "Team could not be updated", team.errors)
  end

  def destroy
    team = Team.find_by(id: params[:team_id])
    return global_error_render(404, "Team not found") unless team

    return global_json_render(200, "Team deleted successfully", serialized_team(team)) if team.destroy
    global_error_render(400, "Team could not be deleted", team.errors)
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
end
