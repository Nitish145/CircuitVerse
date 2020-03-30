require 'rails_helper'

RSpec.describe "Featured Projects Requests", :type => :request do

  let!(:project) { FactoryBot.create(:project, project_access_type: "Public") }
  let!(:featured_circuit) { FeaturedCircuit.create(project_id: project.id) }

  describe "GET all featured projects" do

    before { get '/api/v0/featured_circuits' }

    let!(:hash_body) { JSON.parse(response.body).with_indifferent_access }

    it 'returns status code 200' do
      expect(response).to have_http_status(:success)
    end

    it 'returns all featured projects' do
      expect(hash_body[:meta][:total_count]).to eq(1)
    end

    it 'checks to be paginated' do
      expect(hash_body[:meta].keys).to match_array(
        ["current_page", "next_page", "prev_page", "total_pages", "total_count"]
      )
    end

  end

end
