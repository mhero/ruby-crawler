class UrlParser
  def self.ensure_https(url)
    url.start_with?("https://") ? url : "https://#{url}"
  end
end
