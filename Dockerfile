FROM ruby:alpine

RUN apk update && apk add git

RUN gem update --system && gem install bundler

RUN mkdir -p /gem
WORKDIR /gem
