## Web Crawler API

This Ruby project exposes an API that allows you to crawl web pages, search for specific content, and capture screenshots of the page, which are stored locally as PNG files. The API also returns metadata like the number of links and images found on the page. It’s designed to streamline web scraping with a simple and flexible interface.


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

