require 'rails_helper'

RSpec.describe 'Teams', type: :request do
  before(:all) do
    @user = FactoryBot.create(:user, admin: true)
    login_params = { email: @user.email, password: @user.password }
    @teams = FactoryBot.create_list(:team, 10)
    @first_team = @teams.first
    @second_team = @teams.second
    @third_team = @teams.third
    @last_team = @teams.last

    post '/login', params: login_params

    auth_token = json['data']['auth_token']
    @request_header = { 'HTTP_AUTH_TOKEN' => "Bearer #{auth_token}" }
  end

  describe "index", :list_teams do
    context "when page and per_page are not specified" do
      before { get '/teams', headers: @request_header }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a success message' do
        expect(json['message']).to eq('Teams retrieved successfully')
      end

      it 'returns the list of teams' do
        expect(json).not_to be_empty
      end

      it 'returns meta data' do
        expect(json['meta']).not_to be_empty
        expect(json['meta']).to include('total')
        expect(json['meta']).to include('page')
        expect(json['meta']).to include('per_page')
        expect(json['meta']).to include('page_count')
      end
    end

    context "when page and per_page are specified" do
      let(:page_params) { {page: 2, per_page: 4} }
      before { get '/teams', params: page_params, headers: @request_header }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a success message' do
        expect(json['message']).to eq('Teams retrieved successfully')
      end

      it 'returns the list of teams' do
        expect(json).not_to be_empty
      end

      it 'returns meta data' do
        expect(json['meta']).not_to be_empty
        expect(json['meta']).to include('total')
        expect(json['meta']).to include('page')
        expect(json['meta']).to include('per_page')
        expect(json['meta']).to include('page_count')
      end
    end
  end

  describe "show", :show_team do
    let(:team_id) { @first_team.id }
    let(:invalid_team_id) { 'a' }

    context "when team exists" do
      before { get "/teams/#{team_id}", headers: @request_header }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a success message' do
        expect(json['message']).to eq('Team retrieved successfully')
      end

      it 'returns the team' do
        expect(json['data']['id']).to eq(@first_team.id)
        expect(json['data']['name']).to eq(@first_team.name)
        expect(json['data']['created_at']).not_to be_empty
        expect(json['data']['updated_at']).not_to be_empty
      end
    end

    context "when team does not exist" do
      before { get "/teams/#{invalid_team_id}", headers: @request_header }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a failure message' do
        expect(json['message']).to eq('Team not found')
      end
    end
  end

  describe "create", :create_team do
    let(:valid_team_attributes) { attributes_for(:team) }
    let(:invalid_team_attributes) { { title: "title" } }

    context "when team creation is successful" do
      before { post '/teams', params: valid_team_attributes, headers: @request_header }

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'returns a success message' do
        expect(json['message']).to eq('Team creation successful')
      end

      it 'returns the team' do
        expect(json['data']).to include("id")
        expect(json['data']['name']).to eq(valid_team_attributes[:name])
        expect(json['data']).to include('created_at')
        expect(json['data']).to include('updated_at')
      end
    end

    context "when team creation is unsuccessful" do
      before { post '/teams', params: invalid_team_attributes, headers: @request_header }

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end

      it 'returns a failure message' do
        expect(json['message']).to eq('Team creation unsuccessful')
      end

      it 'returns an array of errors' do
        expect(json['errors']).not_to be_empty
      end
    end
  end

  describe "update", :update_team do
    let(:valid_team_attributes) { attributes_for(:team) }
    let(:empty_team_attributes) { { name: "" } }
    let(:invalid_team_attributes) { { title: "title" } }

    context "when team exists" do
      context "team update successful" do
        before { patch "/teams/#{@first_team.id}", params: valid_team_attributes, headers: @request_header }
  
        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
  
        it 'returns a success message' do
          expect(json['message']).to eq('Team updated successfully')
        end
  
        it 'returns the team' do
          expect(json['data']['id']).to eq(@first_team.id)
          expect(json['data']['name']).to eq(valid_team_attributes[:name])
          expect(json['data']).to include('created_at')
          expect(json['data']).to include('updated_at')
        end
      end
  
      context "team update unsuccessful" do
        context "name not provided" do
          before { patch "/teams/#{@first_team.id}", params: invalid_team_attributes, headers: @request_header }

          it 'returns status code 400' do
            expect(response).to have_http_status(400)
          end
    
          it 'returns a failure message' do
            expect(json['message']).to eq('name must be provided')
          end
        end

        context "name provided" do
          before { patch "/teams/#{@first_team.id}", params: empty_team_attributes, headers: @request_header }

          it 'returns status code 400' do
            expect(response).to have_http_status(400)
          end
    
          it 'returns a failure message' do
            expect(json['message']).to eq('Team could not be updated')
          end

          it 'returns an array of errors' do
            expect(json['errors']).not_to be_empty
          end
        end
        
      end
    end

    context "when team does not exist" do
      before { patch "/teams/a", params: valid_team_attributes, headers: @request_header }
      
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a failure message' do
        expect(json['message']).to eq('Team not found')
      end
    end

  end

  describe "delete", :delete_team do
    context "when team exists" do
      before { delete "/teams/#{@last_team.id}", headers: @request_header }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a success message' do
        expect(json['message']).to eq('Team deleted successfully')
      end

      it 'returns the team' do
        expect(json['data']['id']).to eq(@last_team.id)
        expect(json['data']['name']).to eq(@last_team.name)
        expect(json['data']['created_at']).not_to be_empty
        expect(json['data']['updated_at']).not_to be_empty
      end
    end

    context "when team does not exist" do
      before { delete "/teams/a", headers: @request_header }
      
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a failure message' do
        expect(json['message']).to eq('Team not found')
      end
    end
  end

  describe "team_fixtures", :team_fixtures do
    let(:valid_params_for_all) { { team_id: @first_team.id } }
    let(:valid_params_for_home) { { team_id: @first_team.id, fixtures: 'home' } }
    let(:valid_params_for_away) { { team_id: @first_team.id, fixtures: 'away' } }
    let(:invalid_params) { { team_id: 'a' } }
    context "when team exists" do
      before do
        create(:fixture, home_team: @first_team, away_team: @second_team)
        create(:fixture, home_team: @first_team, away_team: @third_team)
        create(:fixture, home_team: @last_team, away_team: @first_team)
      end

      context "when retrieving all fixtures" do
        before { get "/teams_fixtures", params: valid_params_for_all, headers: @request_header }

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'returns a success message' do
          expect(json['message']).to eq("All fixtures for #{@first_team.name} retrieved successfully")
        end

        it 'returns the team record' do
          expect(json['data']['team']).not_to be_empty
          expect(json['data']['team']['id']).to eq(@first_team.id)
          expect(json['data']['team']['name']).to eq(@first_team.name)
          expect(json['data']['team']['created_at']).not_to be_empty
          expect(json['data']['team']['updated_at']).not_to be_empty
        end

        it "returns the fixtures" do
          expect(json['data']['team']['fixtures']).not_to be_empty
          expect(json['data']['team']['fixtures'].size).to eq(3)
        end
      end

      context "when retrieving only home fixtures" do
        before { get "/teams_fixtures", params: valid_params_for_home, headers: @request_header }

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'returns a success message' do
          expect(json['message']).to eq("Home fixtures for #{@first_team.name} retrieved successfully")
        end

        it 'returns the team record' do
          expect(json['data']['team']).not_to be_empty
          expect(json['data']['team']['id']).to eq(@first_team.id)
          expect(json['data']['team']['name']).to eq(@first_team.name)
          expect(json['data']['team']['created_at']).not_to be_empty
          expect(json['data']['team']['updated_at']).not_to be_empty
        end

        it "returns the fixtures" do
          expect(json['data']['team']['fixtures']).not_to be_empty
          expect(json['data']['team']['fixtures'].size).to eq(2)
        end
      end

      context "when retrieving only away fixtures" do
        before { get "/teams_fixtures", params: valid_params_for_away, headers: @request_header }

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'returns a success message' do
          expect(json['message']).to eq("Away fixtures for #{@first_team.name} retrieved successfully")
        end

        it 'returns the team record' do
          expect(json['data']['team']).not_to be_empty
          expect(json['data']['team']['id']).to eq(@first_team.id)
          expect(json['data']['team']['name']).to eq(@first_team.name)
          expect(json['data']['team']['created_at']).not_to be_empty
          expect(json['data']['team']['updated_at']).not_to be_empty
        end

        it "returns the fixtures" do
          expect(json['data']['team']['fixtures']).not_to be_empty
          expect(json['data']['team']['fixtures'].size).to eq(1)
        end
      end
    end

    context "when team does not exist" do
      before { get "/teams_fixtures", params: invalid_params, headers: @request_header }
      
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a failure message' do
        expect(json['message']).to eq('Team not found')
      end
    end
  end
end