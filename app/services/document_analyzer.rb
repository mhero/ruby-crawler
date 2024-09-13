class DocumentAnalyzer
  def self.call(doc)
    new(doc).call
  end

  def initialize(doc)
    @doc = doc
  end

  def call
    self
  end

  def text_exists?(text)
    doc&.text&.include?(text) || false
  end

  def extract_links
    doc&.css("a")&.map { |link| link["href"] }&.compact&.uniq || []
  end

  def count_urls
    extract_links.count
  end

  def count_images
    doc&.css("img")&.count || 0
  end

  private

  attr_reader :doc
end
