require 'rails_helper'

RSpec.describe Screenshoter, type: :model do
  let(:url) { 'https://example.com' }
  let(:output_path) { 'output/screenshot.png' }
  let(:temp_screenshot_path) { Rails.root.join("tmp", "screenshot_0.png").to_s }

  before do
    allow(Rails).to receive_message_chain(:root, :join).and_return(Dir.tmpdir)
    allow(SecureRandom).to receive(:uuid).and_return('test_uuid')
    allow(FileUtils).to receive(:mv)
    allow(File).to receive(:delete)
    allow_any_instance_of(Screenshoter).to receive(:system).and_return(true)

    Capybara.register_driver :selenium do |app|
      Capybara::Selenium::Driver.new(app, browser: :firefox, options: Selenium::WebDriver::Firefox::Options.new)
    end
  end

  describe '.capture' do
    it 'creates a new instance and calls capture' do
      expect_any_instance_of(Screenshoter).to receive(:capture)
      Screenshoter.capture(url, output_path)
    end
  end

  describe '#capture' do
    subject { described_class.new(url, output_path) }

    it 'visits the URL, waits for the page to load, and captures screenshots' do
      expect(subject).to receive(:visit).with(url)
      expect(subject).to receive(:wait_for_page_to_load)
      expect(subject).to receive(:capture_full_page_screenshot)
      subject.capture
    end
  end

  describe '#wait_for_page_to_load' do
    it 'waits for the page to load' do
      subject = described_class.new(url, output_path)
      allow(subject.page).to receive(:has_css?).with("body", wait: 10).and_return(true)
      subject.send(:wait_for_page_to_load)
    end
  end

  describe '#capture_full_page_screenshot' do
    let(:total_height) { 3000 }
    let(:viewport_height) { 1080 }
    let(:overlap) { 50 }

    it 'captures screenshots of the page in sections' do
      subject = described_class.new(url, output_path)

      browser_double = double('browser')
      allow(browser_double).to receive(:save_screenshot)
      driver_double = double('driver', browser: browser_double)
      page_double = double('page', driver: driver_double)

      allow(subject).to receive(:page).and_return(page_double)
      allow(subject.page).to receive(:execute_script).and_return(nil)

      screenshot_path = Rails.root.join("tmp", "screenshot_0.png").to_s
      allow(subject.page.driver.browser).to receive(:save_screenshot).with(screenshot_path).and_return(true)

      num_screenshots = (total_height.to_f / (viewport_height - overlap)).ceil
      expect(browser_double).to receive(:save_screenshot).exactly(num_screenshots).times

      expect(subject).to receive(:combine_images).with(anything)

      subject.send(:capture_full_page_screenshot, total_height)
    end
  end

  describe '#combine_images' do
    it 'raises an error if combining images fails' do
      subject = described_class.new(url, output_path)

      allow(Open3).to receive(:capture3).and_return([ '', 'error message', double(success?: false) ])

      expect { subject.send(:combine_images, [ temp_screenshot_path ]) }.to raise_error(RuntimeError, /Failed to combine images: error message/)
    end
  end
end
