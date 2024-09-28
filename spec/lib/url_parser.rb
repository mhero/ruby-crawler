require 'rails_helper'

RSpec.describe UrlParser do
  describe '#ensure_https' do
    it 'prepends https to a non-https URL' do
      service = UrlParser.new('example.com')
      expect(service.send(:ensure_https, 'example.com')).to eq('https://example.com')
    end

    it 'returns the URL if it already starts with https' do
      service = UrlParser.new('https://example.com')
      expect(service.send(:ensure_https, 'https://example.com')).to eq('https://example.com')
    end
  end
end
