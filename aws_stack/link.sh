[~] $ curl https://gitlab.com/-/snippets/2565205/raw/main/install_docker.sh
#!/bin/bash

# Install Docker
curl -fsSL https://get.docker.com | sudo bash

# Add the current user to the docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

(
    sudo systemctl start docker && sudo systemctl enable docker
)


[~] $ curl https://gitlab.com/-/snippets/2565205/raw/main/treafik_whoami.sh
#!/bin/bash

# Create and Start Docker Compose
sudo mkdir -p /opt/app
cat << EOF > /opt/app/docker-compose.yml
version: "3"
services:
  whoami:
    image: traefik/whoami:v1.10
    restart: always
    environment:
      - WHOAMI_PORT_NUMBER=8080
    ports:
      - 80:8080
EOF

# Start docker-compose
sudo docker-compose -f /opt/app/docker-compose.yml up -d



[~] $ curl https://gitlab.com/-/snippets/2565205/raw/main/install_docker.sh
#!/bin/bash

# Install Docker
curl -fsSL https://get.docker.com | sudo bash

# Add the current user to the docker group
sudo usermod -aG docker $USER

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s | tr '[:upper:]' '[:lower:]')-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

(
    sudo systemctl start docker && sudo systemctl enable docker
)


[~] $ curl https://gitlab.com/-/snippets/2565205/raw/main/docker_run_service.sh 
#!/bin/bash

# check for env var IAMGE_URI or use default nginx image
IAMGE=${IMAGE_URI:-"nginx"}

# check for env var PORT or use default 80
PORT=${IAMGE_PORT:-"80"}

#!/bin/bash

# Create and Start Docker Compose
sudo mkdir -p /opt/app
cat << EOF > /opt/app/docker-compose.yml
version: "3"
services:
  whoami:
    image: ${IAMGE}
    restart: always
    ports:
      - ${PORT}:${PORT}
EOF

# Start docker-compose
sudo docker-compose -f /opt/app/docker-compose.yml up -d



