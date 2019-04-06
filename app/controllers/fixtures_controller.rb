class FixturesController < ApplicationController
  before_action :authenticate_user_from_headers!
  before_action :check_admin!, except: [:index, :show]

  def index
    params[:page] ||= 1
    params[:per_page] ||= 20
    if params[:match_date]
      valid_date_format, date_filter = fixture_query_valid_match_date_format?(params[:match_date])
      global_error_render(400, "Invalid match_date format") unless valid_date_format
    end

    fixtures = Fixture.search(params[:team_name], params[:team_fixtures], params[:status], date_filter, params[:match_date]).paginate(page: params[:page].to_i, per_page: params[:per_page].to_i)
    data = serialized_fixtures(fixtures)

    counter = fixtures.total_entries
    meta = {
      total: counter,
      per_page: params[:per_page].to_i,
      page: params[:page].to_i,
      page_count: counter.zero? ? 1 : (counter / params[:per_page].to_f).ceil
    }

    global_json_render(200, "Fixtures retrieved successfully", data, meta, true)
  end

  def show
    fixture = Fixture.find_by(id: params[:fixture_id])

    return global_json_render(200, "Fixture retrieved successfully", serialized_fixture(fixture)) if fixture
    global_error_render(404, "Fixture not found")
  end

  def create
    return global_error_render(400, "match_date must be specified in the format: yyyy-mm-ddThh:mm") if fixture_creation_invalid_match_date_format?(params[:match_date])

    fixture_already_exists  = Fixture.exists?(home_team_id: params[:home_team_id], away_team_id: params[:away_team_id])
    return global_error_render(400, "Fixture already exists") if fixture_already_exists

    fixture = Fixture.new(fixture_params)

    return global_json_render(201, "Fixture creation successful", serialized_fixture(fixture)) if fixture.save
    global_error_render(400, "Fixture creation unsuccessful", fixture.errors)
  end

  def update
    fixture = Fixture.find_by(id: params[:fixture_id])
    return global_error_render(404, "Fixture not found") unless fixture

    fixture_already_exists  = Fixture.exists?(home_team_id: params[:home_team_id], away_team_id: params[:away_team_id])
    return global_error_render(400, "Fixture already exists") if fixture_already_exists

    return global_json_render(200, "Fixture updated successfully", serialized_fixture(fixture)) if fixture.update_attributes(fixture_params)
    global_error_render(400, "Fixture could not be updated", fixture.errors)
  end

  def destroy
    fixture = Fixture.find_by(id: params[:fixture_id])
    return global_error_render(404, "Fixture not found") unless fixture

    return global_json_render(200, "Fixture deleted successfully", serialized_fixture(fixture)) if fixture.destroy
    global_error_render(400, "Fixture could not be deleted", fixture.errors)
  end

  private
  
  def fixture_params
    params.permit(:home_team_id, :away_team_id, :match_date, :home_team_goals, :away_team_goals)
  end

  def serialized_fixture(fixture)
    data = FixtureSerializer.new(fixture).serializable_hash
    data.dig(:data, :attributes)
  end

  def serialized_fixtures(fixtures)
    data = FixtureSerializer.new(fixtures).serializable_hash
    data = data[:data].map do |fixture|
      fixture.dig(:attributes)
    end
    data
  end

  def fixture_creation_invalid_match_date_format?(match_date)
    match_date !~ /\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d$/
  end

  def fixture_query_valid_match_date_format?(match_date)
    acceptable_formats = [
      /\d{4}-[01]\d-[0-3]\dT[0-2]\d:[0-5]\d$/,
      /\d{4}-[01]\d-[0-3]\d$/,
      /\d{4}-[01]\d$/,
      /\d{4}$/
    ]

    filter_by = ['datetime', 'day', 'month', 'year']
    # match = acceptable_formats.any?{|regex| regex =~ match_date }
    acceptable_formats.each_with_index do |regex,index|
      return true, filter_by[index] if regex =~ match_date
    end

    return false, nil
  end
end
