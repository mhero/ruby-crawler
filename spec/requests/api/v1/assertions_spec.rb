require 'rails_helper'

RSpec.describe "Api::V1::Assertions", type: :request do
  let!(:assertion) { create(:assertion) } # Assumes you have a factory for Assertion
  let(:valid_attributes) { { url: 'https://example.com', text: 'Example Domain' } }
  let(:invalid_attributes) { { url: '', text: 'Example Domain' } }

  describe "GET /api/v1/assertions" do
    it "returns a list of assertions" do
      get '/api/v1/assertions'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(assertion.url)
    end
  end

  describe "GET /api/v1/assertions/:id" do
    it "returns the requested assertion" do
      get "/api/v1/assertions/#{assertion.id}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(assertion.url)
    end
  end

  describe "POST /api/v1/assertions" do
    context "with valid parameters" do
      it "creates a new assertion" do
        expect {
          post '/api/v1/assertions', params: { assertion: valid_attributes }
        }.to change(Assertion, :count).by(1)

        expect(response).to have_http_status(:created)
        expect(response.body).to include('https://example.com')
      end
    end

    context "with invalid parameters" do
      it "does not create a new assertion" do
        expect {
          post '/api/v1/assertions', params: { assertion: invalid_attributes }
        }.to change(Assertion, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Invalid URL")
      end
    end
  end

  describe "DELETE /api/v1/assertions/:id" do
    it "deletes the requested assertion" do
      expect {
        delete "/api/v1/assertions/#{assertion.id}"
      }.to change(Assertion, :count).by(-1)

      expect(response).to have_http_status(:no_content)
    end
  end
end
