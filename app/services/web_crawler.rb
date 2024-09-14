class WebCrawler
  attr_reader :url, :doc

  def initialize(url)
    @url = url
    @doc = fetch_page
  end

  def fetch_page
    Nokogiri::HTML(URI.open(ensure_https(url)))
  rescue StandardError => e
    puts "Failed to fetch the page: #{e.message}"
    nil
  end

  def text_exists?(text)
    return false unless doc

    doc.text.include?(text)
  end

  private

  def ensure_https(url)
    unless url.start_with?("https://")
      url = "https://#{url}"
    end
    url
  end
end
