require 'rails_helper'

RSpec.describe 'Users', type: :request do
  before(:all) do
    @user = FactoryBot.create(:user, admin: true)
    login_params = { email: @user.email, password: @user.password }
    @users = FactoryBot.create_list(:user, 10)
    @first_user = @users.first
    @last_user = @users.last

    post '/login', params: login_params

    auth_token = json['data']['auth_token']
    @request_header = { 'HTTP_AUTH_TOKEN' => "Bearer #{auth_token}" }
  end

  describe "show", :show_user do
    context "when user exists" do
      context "when admin requests for specific user" do
        before { get "/users/#{@first_user.id}", headers: @request_header }

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'returns a success message' do
          expect(json['message']).to eq('User retrieved successfully')
        end

        it 'returns the user' do
          expect(json['data']['id']).to eq(@first_user.id)
          expect(json['data']['email']).to eq(@first_user.email)
          expect(json['data']['first_name']).to eq(@first_user.first_name)
          expect(json['data']['last_name']).to eq(@first_user.last_name)
        end
      end

      context "when retrieving logged_in user's details" do
        before { get "/user", headers: @request_header }

        it 'returns status code 200' do
          expect(response).to have_http_status(200)
        end

        it 'returns a success message' do
          expect(json['message']).to eq('User retrieved successfully')
        end

        it 'returns the user' do
          expect(json['data']['id']).to eq(@user.id)
          expect(json['data']['email']).to eq(@user.email)
          expect(json['data']['first_name']).to eq(@user.first_name)
          expect(json['data']['last_name']).to eq(@user.last_name)
        end
      end
    end

    context "when user does not exist" do
      before { get "/users/a", headers: @request_header }
      
      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end

      it 'returns a failure message' do
        expect(json['message']).to eq('User not found')
      end
    end
  end

  describe "index", :list_users do
    context "when page and per_page not specified" do
      before { get '/users', headers: @request_header }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a success message' do
        expect(json['message']).to eq('Users retrieved successfully')
      end

      it 'returns the list of users' do
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

    context "when page and per_page specified" do
      let(:page_params) { {page: 2, per_page: 4} }
      before { get '/users', params: page_params, headers: @request_header }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a success message' do
        expect(json['message']).to eq('Users retrieved successfully')
      end

      it 'returns the list of users' do
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
  
  describe "update", :update_user do
    let(:valid_user_attributes) { attributes_for(:user) }
    let(:invalid_user_attributes) { { first_name: "" } }

    context "when user update is successful" do
      before { post "/user/update", params: valid_user_attributes, headers: @request_header }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a success message' do
        expect(json['message']).to eq('User updated successfully')
      end

      it 'returns the user' do
        expect(json['data']['id']).to eq(@user.id)
        expect(json['data']['email']).to eq(@user.email)
        expect(json['data']['first_name']).to eq(valid_user_attributes[:first_name])
        expect(json['data']['last_name']).to eq(valid_user_attributes[:last_name])
        expect(json['data']).to include('created_at')
        expect(json['data']).to include('updated_at')
      end
    end

    context "when user update is unsuccessful" do
      before { post "/user/update", params: invalid_user_attributes, headers: @request_header }

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end

      it 'returns a failure message' do
        expect(json['message']).to eq('Error updating user profile')
      end

      it 'returns an array of errors' do
        expect(json['errors']).not_to be_empty
      end
    end
  end
end