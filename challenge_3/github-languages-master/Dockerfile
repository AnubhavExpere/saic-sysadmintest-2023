FROM ruby:2.3.1-alpine
RUN apk add --update \
    build-base \
    mariadb-dev \
    sqlite-dev \
    nodejs \
    tzdata \
    && rm -rf /var/cache/apk/*

RUN gem install bundler -v '2.3.26'

WORKDIR /app

COPY . /app/
COPY Gemfile ./

RUN bundle install

EXPOSE 3000

CMD rm -f tmp/pids/server.pid && rails s -b '0.0.0.0'