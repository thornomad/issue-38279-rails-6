FROM ruby:2.6.3-alpine as base

RUN apk --update add -t build-deps \
  build-base \
  postgresql-dev \
  git

RUN apk --update add \
  tzdata \
  postgresql-client \
  bash \
  coreutils \
  less

ENV PATH="./bin:${PATH}"

WORKDIR /app

CMD [ "./bin/rails", "s" ]
