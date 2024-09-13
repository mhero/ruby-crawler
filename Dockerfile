FROM ruby:3.3.5-bullseye

ENV APP_HOME /myapp
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

# Install ImageMagick and its dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y libmagickwand-dev imagemagick && \
    rm -rf /var/lib/apt/lists/*

RUN gem install bundler -v 2.3.3 && bundle config jobs 7
RUN gem install rake -v 13.2.1

ADD Gemfile $APP_HOME/
ADD Gemfile.lock  $APP_HOME/
RUN bundle install

ADD Gemfile.tip $APP_HOME/
RUN bundle install

ADD . $APP_HOME