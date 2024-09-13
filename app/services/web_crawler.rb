class WebCrawler
  def self.call(url)
    new(url).call
  end

  def initialize(url)
    @url = ensure_https(url)
  end

  def call
    fetch_page
  end

  private

  attr_reader :url

  def fetch_page
    Outcome.success(Nokogiri::HTML(URI.open(url)))
  rescue StandardError => e
    Rails.logger.error "Failed to fetch the page: #{e.message}"
    Outcome.failure(e.message)
  end

  def ensure_https(url)
    url.start_with?("https://") ? url : "https://#{url}"
  end
end
