FROM ruby:4.0.9-trixie

ENV APP_HOME=/myapp
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    libmagickwand-dev \
    imagemagick \
    firefox-esr \
    wget \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install latest GeckoDriver
ENV GECKODRIVER_VERSION=v0.37.1

RUN wget -q "https://github.com/mozilla/geckodriver/releases/download/${GECKODRIVER_VERSION}/geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz" && \
    tar -xzf geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz && \
    mv geckodriver /usr/local/bin/ && \
    chmod +x /usr/local/bin/geckodriver && \
    rm geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz

# Install latest Bundler and Rake
RUN gem install bundler rake && bundle config set jobs 7

# Install dependencies
COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY Gemfile.tip ./
RUN bundle install

COPY . .