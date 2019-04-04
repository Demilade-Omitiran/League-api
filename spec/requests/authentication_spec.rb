require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  describe "register", :register do
    let(:valid_user_attributes) { attributes_for(:user) }
    let(:invalid_user_attributes) { { title: "some_title" } }

    context "valid_user_attributes" do
      before { post '/register', params: valid_user_attributes }

      it 'returns status code 201' do
        expect(response).to have_http_status(201)
      end

      it 'returns a success message' do
        expect(json['message']).to eq('Registration successful')
      end

      it 'returns the id and email of the user' do
        expect(json['data']).to include("id")
        expect(json['data']['email']).to eq(valid_user_attributes[:email])
      end

      it 'returns the auth_token' do
        expect(json['data']).to include("auth_token")
      end
    end

    context "invalid_user_attributes" do
      before { post '/register', params: invalid_user_attributes }

      it 'returns status code 400' do
        expect(response).to have_http_status(400)
      end

      it 'returns a failure message' do
        expect(json['message']).to eq('Registration unsuccessful')
      end

      it 'returns an array of errors' do
        expect(json['errors']).not_to be_empty
      end
    end
  end

  describe "login", :login do
    let(:user) { create(:user) }
    let(:valid_login_params) { { email: user.email, password: user.password } }
    let(:invalid_login_params) {{ email: user.email, password: '123' }}

    context "successful" do
      before { post '/login', params: valid_login_params }

      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end

      it 'returns a success message' do
        expect(json['message']).to eq('User login successful')
      end

      it 'returns an auth_token' do
        expect(json['data']['auth_token']).not_to be_empty
      end

      it 'returns user id and email' do
        expect(json['data']['user']['id']).to eq(user.id)
        expect(json['data']['user']['email']).to eq(user.email)
      end
    end

    context "unsuccessful" do
      before { post '/login', params: invalid_login_params }

      it 'returns status code 401' do
        expect(response).to have_http_status(401)
      end

      it 'returns a failure message' do
        expect(json['message']).to eq('Invalid login details')
      end
    end
  end

  describe "logout", :logout do
    let(:user) { create(:user) }
    let(:valid_login_params) { { email: user.email, password: user.password } }

    before do
      post '/login', params: valid_login_params
      auth_token = json['data']['auth_token']
      logout_header = { 'HTTP_AUTH_TOKEN' => "Bearer #{auth_token}" }

      post '/logout', params: nil, headers: logout_header
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end

    it 'returns a success message' do
      expect(json['message']).to eq('Logout successful')
    end
  end
end