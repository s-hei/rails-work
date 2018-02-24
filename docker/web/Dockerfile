FROM ruby:2.5-alpine

RUN apk update && \
    apk upgrade && \
    apk add --update build-base mysql-dev nodejs tzdata imagemagick-dev && \
    rm -rf /var/cache/apk/*

ENV app /work/web
WORKDIR $app

# bundle install pathをdata containarに変更
ENV BUNDLE_PATH /bundle

ARG app_dir
COPY $app_dir $app

VOLUME /work/web/tmp
