require 'rails_helper'

RSpec.describe WebCrawler, type: :service do
  let(:url) { 'https://example.com' }

  describe '.call' do
    context 'when the URL is valid' do
      it 'fetches the page content successfully' do
        allow(URI).to receive(:open).with(url).and_return('<html><body>Hello</body></html>')
        result = WebCrawler.call(url)

        expect(result.success?).to be true
        expect(result.value).to be_a(Nokogiri::HTML::Document)
        expect(result.value.text).to include('Hello')
      end
    end

    context 'when the URL is invalid' do
      before do
        allow(URI).to receive(:open).and_raise(StandardError.new('OpenURI Error'))
        allow(Rails.logger).to receive(:error)
      end

      it 'logs the error and returns a failure result' do
        result = WebCrawler.call(url)

        expect(result.failure?).to be true
        expect(result.message).to eq('OpenURI Error')
        expect(Rails.logger).to have_received(:error).with("Failed to fetch the page: OpenURI Error")
      end
    end
  end
end
