#!/bin/bash

# Options

set -e


# Clone the repository

rm -rf /tmp/docker-lamp
git clone https://github.com/fbenard/docker-lamp /tmp/docker-lamp


# Copy run.sh

cp -f /tmp/docker-lamp/run.sh /usr/local/bin/docker-lamp
chmod +x /usr/local/bin/docker-lamp


# Remove the repository

rm -rf /tmp/docker-lamp
