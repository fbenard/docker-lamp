#!/bin/bash

# Options

set -e


# Clone the repository

rm -rf /tmp/docker-web
git clone https://github.com/fbenard/docker-web /tmp/docker-web


# Copy run.sh

cp -f /tmp/docker-web/scripts/run.sh /usr/local/bin/docker-web
chmod +x /usr/local/bin/docker-web


# Remove the repository

rm -rf /tmp/docker-web
