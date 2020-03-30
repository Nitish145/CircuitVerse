require 'rails_helper'

RSpec.describe "User Details Requests", :type => :request do

  let!(:user) { FactoryBot.create(:user) }

  context "Unauthorized requests" do

    before { get '/api/v0/user/me' }
    let!(:hash_body) { JSON.parse(response.body).with_indifferent_access }

    it 'returns status code 401' do
      expect(response).to have_http_status(:unauthorized)
    end

  end

  context "Authorized GET requests" do

    before do
      token = JsonWebToken.encode(user_id: user.id)
      headers = { "Authorization" => "Token #{token}" }
      get '/api/v0/user/me', :headers => headers
    end

    let!(:hash_body) { JSON.parse(response.body).with_indifferent_access }

    it 'returns status code 200' do
      expect(response).to have_http_status(:success)
    end

    it 'returns valid Json' do
      expect(response.body).to eq(UserSerializer.new(user).serialized_json)
    end

  end

  context "Authorized PATCH requests" do

    before do
      token = JsonWebToken.encode(user_id: user.id)
      headers = { "Authorization" => "Token #{token}" }
      patch '/api/v0/user/me',:params => { :name => "Edited Name" }, :headers => headers
    end

    let!(:hash_body) { JSON.parse(response.body).with_indifferent_access }

    it 'returns status code 202' do
      expect(response).to have_http_status(:accepted)
    end

    it 'expects new user name' do
      expect(hash_body[:data][:attributes][:name]).to eq("Edited Name")
    end

  end

end
