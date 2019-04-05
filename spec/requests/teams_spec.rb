require 'rails_helper'

RSpec.describe 'Teams', type: :request do
  before(:all) do
    @user = FactoryBot.create(:user, admin: true)
    login_params = { email: @user.email, password: @user.password }
    @teams = FactoryBot.create_list(:team, 10)
    @first_team = @teams.first
    @last_team = @teams.last

    post '/login', params: login_params

    auth_token = json['data']['auth_token']
    @request_header = { 'HTTP_AUTH_TOKEN' => "Bearer #{auth_token}" }
  end

  after(:all) do
    Faker::UniqueGenerator.clear
  end

  describe "index", :list_teams do
    context "page and per_page not specified" do
      before { get '/teams', headers: @request_header }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a success message' do
        expect(json['message']).to eq('Teams retrieved successfully')
      end

      it 'returns the list of teams' do
        expect(json).not_to be_empty
        expect(json['data'].size).to eq(10)
      end

      it 'returns meta data' do
        expect(json['meta']).not_to be_empty
        expect(json['meta']['total']).to eq(10)
        expect(json['meta']['page']).to eq(1)
        expect(json['meta']['per_page']).to eq(20)
        expect(json['meta']['page_count']).to eq(1)
      end
    end

    context "page and per_page specified" do
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
        expect(json['data'].size).to eq(4)
      end

      it 'returns meta data' do
        expect(json['meta']).not_to be_empty
        expect(json['meta']['total']).to eq(10)
        expect(json['meta']['page']).to eq(2)
        expect(json['meta']['per_page']).to eq(4)
        expect(json['meta']['page_count']).to eq(3)
      end
    end
  end

  describe "show", :show_team do
    let(:team_id) { @first_team.id }
    let(:invalid_team_id) { 'a' }

    context "team exists" do
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

    context "team does not exist" do
      before { get "/teams/#{invalid_team_id}", headers: @request_header }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a success message' do
        expect(json['message']).to eq('Team not found')
      end
    end
  end

  describe "create", :create_team do
    let(:valid_team_attributes) { attributes_for(:team) }
    let(:invalid_team_attributes) { { title: "title" } }

    context "team creation successful" do
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

    context "team creation unsuccessful" do
      before { post '/teams', params: invalid_team_attributes, headers: @request_header }

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end

      it 'returns a failure message' do
        expect(json['message']).to eq('Team creation unsuccessful')
      end

      it 'returns an array of errors' do
        expect(json['data']['errors']).not_to be_empty
      end
    end
  end

  describe "update", :update_team do
    let(:valid_team_attributes) { attributes_for(:team) }
    let(:empty_team_attributes) { { name: "" } }
    let(:invalid_team_attributes) { { title: "title" } }

    context "team exists" do
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

    context "team does not exist" do
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
    context "team exists" do
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

    context "team does not exist" do
      before { delete "/teams/a", headers: @request_header }
      
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a failure message' do
        expect(json['message']).to eq('Team not found')
      end
    end
  end
end