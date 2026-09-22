#!/bin/bash
bundle config set --local clean 'true'
bundle config set --local path 'vendor/bundle'
# A restored cache can hold a git-sourced gem whose checkout is missing the pinned
# revision, which bundler reports as "Could not parse object" and cannot recover from.
bundle install || { rm -rf vendor/bundle; bundle install; }
