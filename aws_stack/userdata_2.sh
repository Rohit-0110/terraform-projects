#!/bin/bash

sudo snap install amazon-ssm-agent --classic
sudo snap start amazon-ssm-agent

curl -sL https://gitlab.com/-/snippets/2565205/raw/main/install_docker.sh | bash
sleep 1

export IMAGE_URI=chentex/go-rest-api
export IAMGE_PORT=8080
curl -sL https://gitlab.com/-/snippets/2565205/raw/main/docker_run_service.sh | bash
