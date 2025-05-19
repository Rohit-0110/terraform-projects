#!/bin/bash

# install docker and docker-compose
curl -sL https://gitlab.com/-/snippets/2565205/raw/main/install_docker.sh | sudo bash
sleep 2
# setup hello world server container
curl -sL https://gitlab.com/-/snippets/2565205/raw/main/treafik_whoami.sh | sudo bash