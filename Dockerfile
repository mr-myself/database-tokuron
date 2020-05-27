FROM ruby:2.6.1

ENV LANG C.UTF-8
ENV BUILD_PACKAGES="ruby-dev bash" \
    DEV_PACKAGES="libxml2-dev libxslt-dev tzdata" \
    RUBY_PACKAGES="ruby-json nodejs"

RUN apt-get update -qq -y && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    wget \
    vim \
    ca-certificates \
    fonts-ipa* \
    $BUILD_PACKAGES \
    $DEV_PACKAGES \
    $RUBY_PACKAGES \
    libfontconfig1 && \
    rm -rf /var/lib/apt/lists/*

ENV APP_DIR=/app/

RUN mkdir $APP_DIR
WORKDIR $APP_DIR

COPY ./Gemfile $APP_DIR
#COPY ./Gemfile.lock $APP_DIR
RUN gem install bundler
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install --no-deployment --quiet

COPY ./ $APP_DIR
