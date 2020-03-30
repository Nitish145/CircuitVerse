require "rails_helper"

RSpec.describe "User Authentication Requests", :type => :request do
  describe "Authenticate User" do

    let!(:cv_user) { FactoryBot.create(:user, email: "test1@test.com", password: "test@123") }

    it "Signs Up a User" do
      headers = { "ACCEPT" => "application/json" }
      post "/api/v0/auth/signup", :params => {
        :name => "test",
        :email => "test_signup@test.com",
        :password => "test@123"
      }, :headers => headers

      expect(response).to have_http_status(:created)
    end

    it "Logs in a User" do
      headers = { "ACCEPT" => "application/json" }
      post "/api/v0/auth/login", :params => {
        :email => "test1@test.com",
        :password => "test@123"
      }, :headers => headers

      expect(response).to have_http_status(:accepted)
    end

  end
end
