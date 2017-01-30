FROM ruby:2.3.1

RUN mkdir /app
ADD . /app
WORKDIR /app
RUN bundle install

CMD bundle exec exe/pinboard-fixup-tweets
