require 'rails_helper'

RSpec.describe WebCrawler, type: :service do
  let(:url) { 'https://example.com' }
  let(:crawler) { WebCrawler.new(url) }

  describe '#initialize' do
    it 'sets the url and fetches the page' do
      expect(crawler.url).to eq(url)
      expect(crawler.doc).to be_a(Nokogiri::HTML::Document)
    end
  end

  describe '#fetch_page' do
    context 'when the URL is valid' do
      it 'fetches the page content successfully' do
        allow(URI).to receive(:open).with(url).and_return('<html><body>Hello</body></html>')
        expect(crawler.doc.text).to include('Hello')
      end
    end

    context 'when the URL is invalid' do
      before do
        allow(URI).to receive(:open).and_raise(StandardError.new('OpenURI Error'))
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error and sets doc to nil' do
        expect(Rails.logger).to receive(:error).with("Failed to fetch the page: OpenURI Error")
        expect(crawler.doc).to be_nil
      end
    end
  end

  describe '#text_exists?' do
    before do
      allow(crawler).to receive(:doc).and_return(Nokogiri::HTML('<html><body>Hello world</body></html>'))
    end

    it 'returns true if the text exists' do
      expect(crawler.text_exists?('world')).to be true
    end

    it 'returns false if the text does not exist' do
      expect(crawler.text_exists?('not here')).to be false
    end
  end

  describe '#extract_links' do
    before do
      allow(crawler).to receive(:doc).and_return(Nokogiri::HTML('<html><body><a href="https://link1.com">Link1</a><a href="https://link2.com">Link2</a></body></html>'))
    end

    it 'returns an array of unique links' do
      expect(crawler.extract_links).to contain_exactly('https://link1.com', 'https://link2.com')
    end
  end

  describe '#count_images' do
    before do
      allow(crawler).to receive(:doc).and_return(Nokogiri::HTML('<html><body><img src="image1.jpg"/><img src="image2.jpg"/></body></html>'))
    end

    it 'returns the number of images on the page' do
      expect(crawler.count_images).to eq(2)
    end
  end

  describe '#count_urls' do
    before do
      allow(crawler).to receive(:doc).and_return(Nokogiri::HTML('<html><body><a href="https://link1.com">Link1</a><a href="https://link2.com">Link2</a></body></html>'))
    end

    it 'returns the number of URLs on the page' do
      expect(crawler.count_urls).to eq(2)
    end
  end

  describe '#ensure_https' do
    it 'prepends https to a non-https URL' do
      expect(crawler.send(:ensure_https, 'example.com')).to eq('https://example.com')
    end

    it 'returns the URL if it already starts with https' do
      expect(crawler.send(:ensure_https, 'https://example.com')).to eq('https://example.com')
    end
  end
end
