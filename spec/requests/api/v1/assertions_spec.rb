require 'rails_helper'

RSpec.describe "Api::V1::Assertions", type: :request do
  let!(:assertion) { create(:assertion) } # Assumes you have a factory for Assertion
  let(:valid_attributes) { { url: 'https://example.com', text: 'Example Domain' } }
  let(:invalid_attributes) { { url: '', text: 'Example Domain' } }
  let(:missing_text_attributes) { { url: 'https://example.com', text: '' } }
  let(:non_existent_id) { -1 }

  describe "GET /api/v1/assertions" do
    context "when there are assertions" do
      it "returns a list of assertions" do
        get '/api/v1/assertions'
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(assertion.url)
      end
    end

    context "when there are no assertions" do
      before { Assertion.delete_all }

      it "returns an empty array" do
        get '/api/v1/assertions'
        expect(response).to have_http_status(:ok)
        expect(JSON.parse(response.body)).to be_empty
      end
    end
  end

  describe "GET /api/v1/assertions/:id" do
    context "when the assertion exists" do
      it "returns the requested assertion" do
        get "/api/v1/assertions/#{assertion.id}"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include(assertion.url)
      end
    end

    context "when the assertion does not exist" do
      it "returns a not found error" do
        get "/api/v1/assertions/#{non_existent_id}"
        expect(response).to have_http_status(:not_found)
        expect(response.body).to include("Couldn't find Assertion")
      end
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

      it "returns a structured JSON response for successful creation" do
        post '/api/v1/assertions', params: { assertion: valid_attributes }

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to have_key("url")
        expect(JSON.parse(response.body)).to have_key("text")
        expect(JSON.parse(response.body)).to have_key("status")
        expect(JSON.parse(response.body)).to have_key("links_number")
        expect(JSON.parse(response.body)).to have_key("images_number")
      end
    end

    context "with invalid parameters" do
      it "does not create a new assertion" do
        expect {
          post '/api/v1/assertions', params: { assertion: invalid_attributes }
        }.to change(Assertion, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Url is not present")
      end

      it "returns a structured JSON response with errors" do
        post '/api/v1/assertions', params: { assertion: invalid_attributes }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("error")
      end
    end

    context "with missing text parameter" do
      it "returns an error for missing text" do
        expect {
          post '/api/v1/assertions', params: { assertion: missing_text_attributes }
        }.to change(Assertion, :count).by(0)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Text is not present")
      end
    end

    context "when the crawler fails" do
      before do
        allow(WebCrawler).to receive(:call).and_return(Outcome.failure('Crawling failed'))
      end

      it "returns an error if the web crawler fails" do
        post '/api/v1/assertions', params: { assertion: valid_attributes }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Crawling failed")
      end
    end

    context "with unexpected parameter keys" do
      it "ignores unexpected parameters" do
        post '/api/v1/assertions', params: { assertion: valid_attributes.merge(unexpected_param: 'unexpected') }

        expect(response).to have_http_status(:created)
        expect(response.body).to include('https://example.com')
      end
    end
  end

  describe "DELETE /api/v1/assertions/:id" do
    context "when the assertion exists" do
      it "deletes the requested assertion" do
        expect {
          delete "/api/v1/assertions/#{assertion.id}"
        }.to change(Assertion, :count).by(-1)

        expect(response).to have_http_status(:no_content)
      end
    end

    context "when the assertion does not exist" do
      it "returns a not found error" do
        delete "/api/v1/assertions/#{non_existent_id}"
        expect(response).to have_http_status(:not_found)
        expect(response.body).to include("Couldn't find Assertion")
      end
    end
  end
end
