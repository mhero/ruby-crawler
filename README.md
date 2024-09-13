## Web crawler app

API exposes a web crawler API

## Dependencies

* Ruby 3.3.5

## Apps info
 * Rails app runs in port 4567 (using this default config)

## Local Development
## Docker install

1. Install dependencies
```
https://www.docker.com/products/docker-desktop
```

2. Clone repository
3. cd into repository folder

4. Run
```
docker-compose up
```

6. Rails debug
```
docker exec -it $( docker ps | grep ruby-crawler | awk "{print \$1}" | head -n 1 ) rails c
```

## Full install

1. Install dependencies
```
brew install node
\curl -sSL https://get.rvm.io | bash
rvm install "ruby-3.3.5"
rvm use 3.3.5
brew install postgresql
```

2. Clone repository
3. cd into repository folder

4. Run in command line next:

```
gem install bundler && bundle config jobs 7
```

5. Replace file with credentials of local postgres db(in development section)
```
database.yml
```

7. Run in command line next:
```
bundle install
```

8. run backend (on aterminal window)
```
rails server --binding 0.0.0.0 --port 4567
```

