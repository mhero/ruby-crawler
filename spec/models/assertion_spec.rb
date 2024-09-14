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
    let(:url) { 'http://example.com' }
    let(:text) { 'Example Domain' }
    let(:params) { ActionController::Parameters.new({ url: url, text: text }) }

    before do
      allow_any_instance_of(WebCrawler).to receive(:text_exists?).and_return(true)
      allow_any_instance_of(WebCrawler).to receive(:count_urls).and_return(5)
      allow_any_instance_of(WebCrawler).to receive(:count_images).and_return(3)
    end

    it 'creates an Assertion with correct attributes' do
      assertion = Assertion.build_from_web_crawler(params)

      expect(assertion).to be_valid
      expect(assertion.url).to eq(url)
      expect(assertion.text).to eq(text)
      expect(assertion.status).to eq('PASS')
      expect(assertion.links_number).to eq(5)
      expect(assertion.images_number).to eq(3)
    end

    context 'when text does not exist on the page' do
      before do
        allow_any_instance_of(WebCrawler).to receive(:text_exists?).and_return(false)
      end

      it 'sets status to FAIL' do
        assertion = Assertion.build_from_web_crawler(params)

        expect(assertion).to be_valid
        expect(assertion.status).to eq('FAIL')
      end
    end

    context 'when URL is missing' do
      let(:params) { ActionController::Parameters.new({ text: text }) }

      it 'returns nil' do
        assertion = Assertion.build_from_web_crawler(params)
        expect(assertion).to be_nil
      end
    end
  end
end
