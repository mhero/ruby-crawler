require 'rails_helper'

RSpec.describe Assertion, type: :model do
  it { should validate_presence_of(:url) }
  it { should validate_presence_of(:text) }
  it { should validate_presence_of(:status) }
  it { should validate_numericality_of(:links_number).only_integer }
  it { should validate_numericality_of(:images_number).only_integer }

  it { should have_db_column(:url).of_type(:string) }
  it { should have_db_column(:text).of_type(:string) }
  it { should have_db_column(:status).of_type(:string) }
  it { should have_db_column(:created_at).of_type(:datetime) }
  it { should have_db_column(:updated_at).of_type(:datetime) }
  it { should have_db_column(:links_number).of_type(:integer) }
  it { should have_db_column(:images_number).of_type(:integer) }

  describe '.build_from_web_crawler' do
    let(:valid_params) { { url: 'https://example.com', text: 'Example text' } }
    let(:invalid_params) { { url: '', text: '' } }

    context 'when the URL is missing' do
      it 'returns a failure outcome with an appropriate message' do
        outcome = Assertion.build_from_web_crawler(invalid_params)
        expect(outcome.failure?).to be true
        expect(outcome.message).to eq('Url is not present')
      end
    end

    context 'when the text is missing' do
      it 'returns a failure outcome with an appropriate message' do
        invalid_params = { url: 'https://example.com', text: '' }
        outcome = Assertion.build_from_web_crawler(invalid_params)
        expect(outcome.failure?).to be true
        expect(outcome.message).to eq('Text is not present')
      end
    end

    context 'when the web crawler fetches the page successfully' do
      let(:mock_doc) { Nokogiri::HTML('<html><body>Hello world <a href="https://link.com">link</a><img src="image.jpg"/></body></html>') }

      before do
        allow(WebCrawler).to receive(:call).and_return(Outcome.success(mock_doc))
        allow(DocumentAnalyzer).to receive(:call).with(mock_doc).and_return(
          instance_double(
            DocumentAnalyzer,
            text_exists?: true,
            count_urls: 1,
            count_images: 1
          )
        )
      end

      it 'returns a successful outcome with a new Assertion object' do
        outcome = Assertion.build_from_web_crawler(valid_params)

        expect(outcome.success?).to be true
        assertion = outcome.value
        expect(assertion).to be_a(Assertion)
        expect(assertion.url).to eq(valid_params[:url])
        expect(assertion.text).to eq(valid_params[:text])
        expect(assertion.status).to eq('PASS')
        expect(assertion.links_number).to eq(1)
        expect(assertion.images_number).to eq(1)
      end
    end

    context 'when the web crawler fails to fetch the page' do
      before do
        allow(WebCrawler).to receive(:call).and_return(Outcome.failure('OpenURI Error'))
      end

      it 'returns a failure outcome with an appropriate message' do
        outcome = Assertion.build_from_web_crawler(valid_params)
        expect(outcome.failure?).to be true
        expect(outcome.message).to eq('OpenURI Error')
      end
    end
  end
end
