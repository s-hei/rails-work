#!/bin/bash

# 更新があればinstall
mkdir -p /work/web/tmp/sockets
bundle check || bundle install -j4
npm install
bundle exec puma -C config/puma.rb
