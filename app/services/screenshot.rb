require "capybara"
require "capybara/dsl"
require "selenium-webdriver"
require "mini_magick"

class Screenshot
  include Capybara::DSL

  def initialize(url, output_path)
    @url = url
    @output_path = output_path

    Capybara.register_driver :selenium do |app|
      options = Selenium::WebDriver::Chrome::Options.new
      options.add_argument("--headless")
      options.add_argument("--disable-gpu")
      options.add_argument("--no-sandbox")

      Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
    end

    Capybara.default_driver = :selenium
  end

  def capture
    visit(@url)

    wait_for_page_to_load

    total_height = page.evaluate_script("document.body.scrollHeight")
    page.driver.browser.manage.window.resize_to(1920, 1080)

    capture_full_page_screenshot(total_height)
  end

  private

  def wait_for_page_to_load
    sleep(5)
  end

  def capture_full_page_screenshot(total_height)
    viewport_height = 1080
    overlap = 50
    screenshots = []

    (0..total_height).step(viewport_height - overlap).each do |offset|
      page.execute_script("window.scrollTo(0, #{offset});")
      sleep(2)

      screenshot_path = Rails.root.join("tmp", "screenshot_#{offset}.png")
      page.driver.browser.save_screenshot(screenshot_path)
      screenshots << screenshot_path
    end

    combine_images(screenshots)

    screenshots.each { |path| File.delete(path) }
  end

  def combine_images(screenshots)
    combined_image_path = Rails.root.join("public", "screenshots", "combined_#{SecureRandom.uuid}.png").to_s.shellescape

    image_files = screenshots.map(&:to_s).shelljoin

    command = "magick #{image_files} -append #{combined_image_path}"
    system(command)

    raise "Failed to combine images" unless $?.success?

    FileUtils.mv(combined_image_path, @output_path)
  end
end
