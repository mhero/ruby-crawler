## Web Crawler App

The API exposes a web crawler.

## Dependencies

- Ruby 3.3.5

## App Info

- Rails app runs on port 4567 (using this default config).

## Local Development

### Docker Install

1. Install dependencies:
   - [Docker Desktop](https://www.docker.com/products/docker-desktop)

2. Clone repository.

3. Navigate into the repository folder.

4. Run:
   ```bash
   docker-compose up
   ```

5. Rails debug:
   ```bash
   docker exec -it $(docker ps | grep ruby-crawler | awk "{print \$1}" | head -n 1) rails c
   ```

### Full Install

1. Install dependencies:
   ```bash
   brew install node
   \curl -sSL https://get.rvm.io | bash
   rvm install "ruby-3.3.5"
   rvm use 3.3.5
   brew install postgresql
   ```

2. Clone repository.

3. Navigate into the repository folder.

4. Run in command line:
   ```bash
   gem install bundler && bundle config jobs 7
   ```

5. Replace the `database.yml` file with credentials for the local PostgreSQL DB.

6. Run in the command line:
   ```bash
   bundle install
   ```

7. Run the backend in a terminal window:
   ```bash
   rails server --binding 0.0.0.0 --port 4567
   ```

## Request Example

### POST

```bash
curl -X POST http://localhost:4567/api/v1/assertions -H "Content-Type: application/json" -d '{"assertion": {"url": "autify.com", "text": "product"}}'
```

### GET

```bash
curl http://localhost:4567/api/v1/assertions -H "Content-Type: application/json"
```

## Approach

This project implements a web crawler API using **Ruby on Rails**. It uses **Nokogiri** for HTML parsing and **PostgreSQL** for storing data.

### Key Features

1. **HTML Parsing with Nokogiri**: 
   - Nokogiri is used to download and parse web pages. It helps find the specified text, count links (`<a>` tags), and count images (`<img>` tags) on the page.
   - **Assumption**: This implementation assumes that all HTML tags on the page are valid. To handle cases of broken or malformed HTML, additional exception handling would need to be added to ensure robustness in such scenarios.

2. **Assertion Endpoint**:
   - The API accepts a URL and text to search for.
   - Nokogiri checks if the text is present on the web page. 
   - The API returns "PASS" if the text is found and "FAIL" if not.

3. **Storing Metadata in PostgreSQL**:
   - Metadata, such as the number of links, images, the result of the assertion, and the timestamp, is saved in a PostgreSQL database.
   - PostgreSQL is used because it works well with Rails and is reliable for storing structured data.

4. **Returning Metadata**:
   - A separate API endpoint retrieves the stored metadata, including the URL, text, result, number of links, images, and when the assertion was made.

5. **Snapshot Feature (Partially Implemented)**:
   - The snapshot feature is partially implemented and allows capturing a screenshot of the web page when an assertion is made.
   - For this feature, the following gems are used:
     - `capybara`
     - `selenium-webdriver`
     - `mini_magick`
     - `shellwords`
   - These libraries automate **Firefox** to capture screenshots and process the images using `mini_magick`.
   - Due to time constraints, [Dhalang](https://github.com/nielssteensma/dhalang) was considered but not implemented.
   - To run the snapshot feature locally:
     1. **Install Firefox** on your machine (if it's not installed already).
     2. Access the Docker container:
        ```bash
        docker exec -it $(docker ps | grep ruby-crawler | awk "{print \$1}" | head -n 1) rails c
        ```
     3. In the Rails console, run:
        ```ruby
        output_path = Rails.root.join("public", "screenshots", "#{SecureRandom.uuid}.png")
        screenshot = Screenshoter.capture("https://autify.com", output_path)
        ```
   - This will save a local (public folder of the Rails project) screenshot of the page.

### Improvements

While these features were not completed due to time constraints, they were part of the project's planned enhancements:

1. **Asynchronous Screenshot Capture**:

   - The call to the `Screenshoter` will be handled asynchronously to avoid blocking the main request flow. When an assertion is submitted, a background job can be triggered with the `Assertion` model ID:
   ```ruby
   ScreenshotJob.call(assertion.id)
   ```
   Once the `Screenshoter` completes, it updates the `Assertion` with the path to the saved image.
   * This was updated after the fact in branch `async-call-screenshot`

2. **External CDN for Image Hosting**:
   - To prevent overloading the project's infrastructure with image storage, we could use a CDN (Content Delivery Network) to host screenshots. This approach would provide faster access to images and reduce the load on the local system.
