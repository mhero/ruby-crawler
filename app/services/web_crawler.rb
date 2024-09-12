class WebCrawler
  attr_reader :url, :doc

  def initialize(url)
    @url = url
    @doc = fetch_page
  end

  def fetch_page
    Nokogiri::HTML(URI.open(ensure_https(url)))
  rescue StandardError => e
    Rails.logger.error "Failed to fetch the page: #{e.message}"
    nil
  end

  def text_exists?(text)
    return false unless doc

    doc.text.include?(text)
  end

  def extract_links
    return [] unless doc

    links = doc.css("a").map { |link| link["href"] }
    links.compact.uniq
  end

  def count_urls
    extract_links.count
  end

  def count_images
    return 0 unless doc

    doc.css("img").count
  end

  private

  def ensure_https(url)
    url = url.start_with?("https://") ? url : "https://#{url}"
  end
end
