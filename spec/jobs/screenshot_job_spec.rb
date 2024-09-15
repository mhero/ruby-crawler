require 'rails_helper'

RSpec.describe ScreenshotJob, type: :job do
  let(:assertion) { create(:assertion, url: "https://example.com") }

  describe '.call' do
    it 'enqueues the job' do
      expect {
        ScreenshotJob.call(assertion.id)
      }.to have_enqueued_job(ScreenshotJob).with(assertion.id)
    end
  end

  describe '#perform' do
    let(:output_path) { Rails.root.join("public", "screenshots", "#{SecureRandom.uuid}.png") }

    before do
      allow(Screenshoter).to receive(:capture).and_return(true)
      allow(SecureRandom).to receive(:uuid).and_return('test-uuid')
    end

    it 'captures a screenshot and updates the assertion' do
      ScreenshotJob.perform_now(assertion.id)

      expect(Screenshoter).to have_received(:capture).with(assertion.url, Rails.root.join("public", "screenshots", "test-uuid.png"))

      assertion.reload
      expect(assertion.local_path).to eq(Rails.root.join("public", "screenshots", "test-uuid.png").to_s)
    end
  end
end
