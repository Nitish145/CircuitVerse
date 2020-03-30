require 'rails_helper'

RSpec.describe "Projects Requests", :type => :request do

  let!(:project_author) { FactoryBot.create(:user) }
  let!(:projects) { FactoryBot.create_list(:project, 5, author: project_author) }

  context "Unauthorized requests" do

    before { get '/api/v0/projects', :headers => headers }
    let!(:hash_body) { JSON.parse(response.body).with_indifferent_access }

    it 'returns status code 401' do
      expect(response).to have_http_status(:unauthorized)
    end

  end

  context "Authorized requests" do

    before do
      token = JsonWebToken.encode(user_id: project_author.id)
      headers = { "Authorization" => "Token #{token}" }
      get '/api/v0/projects', :headers => headers
    end

    let!(:hash_body) { JSON.parse(response.body).with_indifferent_access }

    it 'returns status code 200' do
      expect(response).to have_http_status(:success)
    end

    it 'returns all users projects' do
      expect(hash_body[:meta][:total_count]).to eq(5)
    end

    it 'checks type for each project' do
      hash_body[:data].each do |project|
        expect(project[:type]).to eq('project')
      end
    end

    it 'checks project object keys' do
      hash_body[:data].each do |project|
        expect(project.keys).to match_array(
          ["attributes", "id", "relationships", "type"]
        )
      end
    end

    it 'checks project attributes keys' do
      hash_body[:data].each do |project|
        expect(project[:attributes].keys).to match_array(
          ["name", "project_access_type", "created_at", "updated_at", "image_preview", "description", "view", "tags", "stars_count"]
        )
      end
    end

    it 'checks if included contains author' do
      hash_body[:included].each do |included|
        expect(included[:type]).to eq("author")
      end
    end

    it 'checks included attributes keys' do
      hash_body[:included].each do |included|
        expect(included[:attributes].keys).to match_array(
          ["name", "email"]
        )
      end
    end

    it 'checks to be paginated' do
      expect(hash_body[:meta].keys).to match_array(
        ["current_page", "next_page", "prev_page", "total_pages", "total_count"]
      )
    end

  end

end
