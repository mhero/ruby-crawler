class Assertion < ApplicationRecord
  validates :url, presence: true
  validates :text, presence: true
  validates :status, presence: true
  validates :links_number, numericality: { only_integer: true }
  validates :images_number, numericality: { only_integer: true }


  def self.build_from_web_crawler(params)
    url = params[:url]
    return nil unless url.present?

    text = params[:text]
    return nil unless url.present?

    crawler = WebCrawler.new(url)

    new(
      url: url,
      text: text,
      status: status(crawler, text),
      links_number: crawler.count_urls,
      images_number: crawler.count_images
    )
  end

  private

  def self.status(crawler, text)
    crawler.text_exists?(text) ? "PASS" : "FAIL"
  end
end
