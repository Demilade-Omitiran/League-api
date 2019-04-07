require 'rails_helper'

RSpec.describe 'Fixtures', type: :request do
  before(:all) do
    @user = FactoryBot.create(:user, admin: true)
    login_params = { email: @user.email, password: @user.password }
    @fixtures = FactoryBot.create_list(:fixture, 5)
    @first_fixture = @fixtures.first
    @last_fixture = @fixtures.last

    post '/login', params: login_params

    auth_token = json['data']['auth_token']
    @request_header = { 'HTTP_AUTH_TOKEN' => "Bearer #{auth_token}" }
  end

  describe "index", :list_fixtures do
    context "when page and per_page are not specified" do
      before { get '/fixtures', headers: @request_header }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a success message' do
        expect(json['message']).to eq('Fixtures retrieved successfully')
      end

      it 'returns the list of fixtures' do
        expect(json).not_to be_empty
        expect(json['data'].size).to eq(5)
      end

      it 'returns meta data' do
        expect(json['meta']).not_to be_empty
        expect(json['meta']['total']).to eq(5)
        expect(json['meta']['page']).to eq(1)
        expect(json['meta']['per_page']).to eq(20)
        expect(json['meta']['page_count']).to eq(1)
      end
    end

    context "when page and per_page are specified" do
      let(:page_params) { { page: 2, per_page: 4} }
      before { get '/fixtures', params: page_params, headers: @request_header }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a success message' do
        expect(json['message']).to eq('Fixtures retrieved successfully')
      end

      it 'returns the list of fixtures' do
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

  describe "show", :show_fixture do
    let(:fixture_id) { @first_fixture.id }
    let(:invalid_fixture_id) { 'a' }

    context "when fixture exists" do
      before { get "/fixtures/#{fixture_id}", headers: @request_header }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a success message' do
        expect(json['message']).to eq('Fixture retrieved successfully')
      end

      it 'returns the fixture' do
        expect(json['data']['id']).to eq(@first_fixture.id)
        expect(json['data']['home_team']).to eq(@first_fixture.home_team.name)
        expect(json['data']['away_team']).to eq(@first_fixture.away_team.name)
        expect(json['data']['status']).to eq(@first_fixture.status)
        expect(json['data']['match_date']).not_to be_empty
        expect(json['data']['created_at']).not_to be_empty
        expect(json['data']['updated_at']).not_to be_empty
      end
    end

    context "when fixture does not exist" do
      before { get "/fixtures/#{invalid_fixture_id}", headers: @request_header }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a failure message' do
        expect(json['message']).to eq('Fixture not found')
      end
    end
  end

  describe "create", :create_fixture do
    before do
      @first_team = create(:team)
      @second_team = create(:team)
    end
    let(:valid_fixture_attributes) { { match_date: "2019-05-04T12:00", home_team_id: @first_team.id, away_team_id: @second_team.id } }
    let(:invalid_fixture_attributes) { { title: "title", match_date: "2019-05-04T12:00" } }

    context "when fixture creation successful" do
      before { post '/fixtures', params: valid_fixture_attributes, headers: @request_header }

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'returns a success message' do
        expect(json['message']).to eq('Fixture creation successful')
      end

      it 'returns the fixture' do
        expect(json['data']).to include("id")
        expect(json['data']['home_team']).to eq(@first_team.name)
        expect(json['data']['away_team']).to eq(@second_team.name)
        expect(json['data']['status']).to eq('pending')
        expect(json['data']).to include('match_date')
        expect(json['data']).to include('created_at')
        expect(json['data']).to include('updated_at')
      end
    end

    context "when fixture creation unsuccessful" do
      before { post '/fixtures', params: invalid_fixture_attributes, headers: @request_header }

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end

      it 'returns a failure message' do
        expect(json['message']).to eq('Fixture creation unsuccessful')
      end

      it 'returns an array of errors' do
        expect(json['errors']).not_to be_empty
      end
    end
  end

  describe "update", :update_fixture do
    let(:fixture) { create(:fixture) }
    let(:valid_fixture_attributes) { { match_date: "2019-02-04T12:00", home_team_goals: 1, away_team_goals: 2 } }
    let(:invalid_feature_attributes) { { home_team_id: fixture.home_team_id, away_team_id: fixture.away_team_id } }

    context "when fixture exists" do
      context "when feature update is successful" do
        before { patch "/fixtures/#{fixture.id}", params: valid_fixture_attributes, headers: @request_header }
  
        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end
  
        it 'returns a success message' do
          expect(json['message']).to eq('Fixture updated successfully')
        end
  
        it 'returns the fixture' do
          expect(json['data']['id']).to eq(fixture.id)
          expect(json['data']['home_team']).to eq(fixture.home_team.name)
          expect(json['data']['away_team']).to eq(fixture.away_team.name)
          expect(json['data']['status']).to eq('completed')
          expect(json['data']).to include('match_date')
          expect(json['data']).to include('created_at')
          expect(json['data']).to include('updated_at')
        end
      end
  
      context "when fixture update is unsuccessful" do
        before { patch "/fixtures/#{fixture.id}", params: invalid_feature_attributes, headers: @request_header }

          it 'returns status code 400' do
            expect(response).to have_http_status(400)
          end
    
          it 'returns a failure message' do
            expect(json['message']).to eq('Fixture already exists')
          end
        end
    end

    context "when fixture does not exist" do
      before { patch "/fixtures/a", params: invalid_feature_attributes, headers: @request_header }
      
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a failure message' do
        expect(json['message']).to eq('Fixture not found')
      end
    end
  end

  describe "delete", :delete_fixture do
    context "when fixtures exists" do
      before { delete "/fixtures/#{@last_fixture.id}", headers: @request_header }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a success message' do
        expect(json['message']).to eq('Fixture deleted successfully')
      end

      it 'returns the fixture' do
        expect(json['data']['id']).to eq(@last_fixture.id)
        expect(json['data']['home_team']).to eq(@last_fixture.home_team.name)
        expect(json['data']['away_team']).to eq(@last_fixture.away_team.name)
        expect(json['data']['status']).to eq(@last_fixture.status)
        expect(json['data']['match_date']).not_to be_empty
        expect(json['data']['created_at']).not_to be_empty
        expect(json['data']['updated_at']).not_to be_empty
      end
    end

    context "when fixture does not exist" do
      before { delete "/fixtures/a", headers: @request_header }
      
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a failure message' do
        expect(json['message']).to eq('Fixture not found')
      end
    end
  end
end