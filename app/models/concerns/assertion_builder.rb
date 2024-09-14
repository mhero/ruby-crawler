# app/models/concerns/assertion_builder.rb
module AssertionBuilder
  extend ActiveSupport::Concern

  class_methods do
    def build_from_web_crawler(params)
      url = params[:url]
      return Outcome.failure("Url is not present") unless url.present?

      text = params[:text]
      return Outcome.failure("Text is not present") unless text.present?

      document_outcome = WebCrawler.call(url)

      if document_outcome.success?
        analyzer = DocumentAnalyzer.call(document_outcome.value)

        Outcome.success(
          Assertion.new(
            url: url,
            text: text,
            status: status(analyzer, text),
            links_number: analyzer.count_urls,
            images_number: analyzer.count_images
          ),
          "Succesful parse"
        )
      else
        Outcome.failure(document_outcome.message)
      end
    end

    private

    def status(analyzer, text)
      analyzer.text_exists?(text) ? "PASS" : "FAIL"
    end
  end
end
