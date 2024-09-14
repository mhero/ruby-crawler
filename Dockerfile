FROM ruby:3.3.5-bullseye

ENV APP_HOME /myapp
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Install ImageMagick and its dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libmagickwand-dev imagemagick firefox-esr wget && \
    rm -rf /var/lib/apt/lists/*

# Install GeckoDriver
ENV GECKODRIVER_VERSION v0.33.0
RUN wget -q "https://github.com/mozilla/geckodriver/releases/download/${GECKODRIVER_VERSION}/geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz" \
    && tar -xzf "geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz" \
    && mv geckodriver /usr/local/bin/ \
    && chmod +x /usr/local/bin/geckodriver \
    && rm geckodriver-${GECKODRIVER_VERSION}-linux64.tar.gz

# Install Bundler and Rake
RUN gem install bundler -v 2.3.3 && bundle config jobs 7
RUN gem install rake -v 13.2.1

ADD Gemfile $APP_HOME/
ADD Gemfile.lock $APP_HOME/
RUN bundle install

ADD Gemfile.tip $APP_HOME/
RUN bundle install

ADD . $APP_HOME
