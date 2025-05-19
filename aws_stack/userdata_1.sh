#!/bin/bash

sudo snap install amazon-ssm-agent --classic
sudo snap start amazon-ssm-agent

curl -sL https://gitlab.com/-/snippets/2565205/raw/main/install_docker.sh | bash
sleep 1
curl -sL https://gitlab.com/-/snippets/2565205/raw/main/treafik_whoami.sh | bash    