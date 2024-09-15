class ScreenshotJob < ApplicationJob
  queue_as :default

  def self.call(assertion_id)
    ScreenshotJob.perform_later(assertion_id)
  end

  def perform(assertion_id)
    assertion = Assertion.find(assertion_id)
    output_path = Rails.root.join("public", "screenshots", "#{SecureRandom.uuid}.png")

    screenshot = Screenshoter.capture(assertion.url, output_path)
  end
end
