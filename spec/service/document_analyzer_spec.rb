require 'rails_helper'

RSpec.describe DocumentAnalyzer, type: :service do
  let(:doc) { Nokogiri::HTML('<html><body><a href="https://link1.com">Link1</a><a href="https://link2.com">Link2</a><img src="image1.jpg"/><img src="image2.jpg"/>Hello world</body></html>') }
  let(:doc_without_links) { Nokogiri::HTML('<html><body><img src="image1.jpg"/><img src="image2.jpg"/>Hello world</body></html>') }
  let(:doc_without_images) { Nokogiri::HTML('<html><body><a href="https://link1.com">Link1</a><a href="https://link2.com">Link2</a>Hello world</body></html>') }


  describe 'full page' do
    let(:analyzer) { DocumentAnalyzer.call(doc) }

    describe '.call' do
      it 'returns the analyzer instance' do
        expect(analyzer).to be_a(DocumentAnalyzer)
      end
    end

    describe '#text_exists?' do
      it 'returns true if the text exists' do
        expect(analyzer.text_exists?('world')).to be true
      end

      it 'returns false if the text does not exist' do
        expect(analyzer.text_exists?('not here')).to be false
      end
    end

    describe '#extract_links' do
      it 'returns an array of unique links' do
        expect(analyzer.extract_links).to contain_exactly('https://link1.com', 'https://link2.com')
      end
    end

    describe '#count_images' do
      it 'returns the number of images on the page' do
        expect(analyzer.count_images).to eq(2)
      end
    end

    describe '#count_urls' do
      it 'returns the number of URLs on the page' do
        expect(analyzer.count_urls).to eq(2)
      end
    end
  end

  describe 'page without links' do
    let(:analyzer) { DocumentAnalyzer.call(doc_without_links) }


    describe '#count_images' do
      it 'returns the number of images on the page' do
        expect(analyzer.count_images).to eq(2)
      end
    end

    describe '#count_urls' do
      it 'returns the number of URLs on the page' do
        expect(analyzer.count_urls).to eq(0)
      end
    end
  end

  describe 'page without images' do
    let(:analyzer) { DocumentAnalyzer.call(doc_without_images) }


    describe '#count_images' do
      it 'returns the number of images on the page' do
        expect(analyzer.count_images).to eq(0)
      end
    end

    describe '#count_urls' do
      it 'returns the number of URLs on the page' do
        expect(analyzer.count_urls).to eq(2)
      end
    end
  end
end
