worker_start_script        = <<EOT
#!/usr/bin/env bash

# Add EFS Mount for a dependency cache
apt update
apt -y install nfs-common
mkdir /dependency_cache
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${var.efs_dns_name}:/ /dependency_cache

# Use the dependency cache for pip
mkdir -p /root/.cache
mkdir -p /dependency_cache/pip_cache
ln -sf /dependency_cache/pip_cache /root/.cache/pip
chown root:docker /root
chown root:docker /root/.cache
chmod -R g+rwx /root

# Wait for instance credentials
until aws sts get-caller-identity
do
  echo "Try again"
  sleep 5
done

# Save login token
DOCKER_LOGIN=$(aws ssm get-parameter --region us-west-2 --with-decryption --output text --query Parameter.Value --name gitlab-runners-dockerhub-token)

# Configure Docker for Root
mkdir -p /root/.docker
echo "{
  \"auths\": {
    \"https://index.docker.io/v1/\": {
      \"auth\": \"$DOCKER_LOGIN\"
    }
  },
  \"experimental\": \"enabled\",
  \"features\": {
    \"buildkit\": \"true\"
  }
}" > /root/.docker/config.json

# Configure Docker for Ubuntu
mkdir -p /home/ubuntu/.docker
cp /root/.docker/config.json /home/ubuntu/.docker/config.json
chown -R ubuntu:ubuntu /home/ubuntu
EOT
  runner_before_start_script = <<EOT
#!/usr/bin/env bash

# Force the AWS CLI to use a valid region
aws configure set region us-west-2

# Wait for instance credentials
until aws sts get-caller-identity
do
  echo "Try again"
  sleep 5
done

# Save login token
DOCKER_LOGIN=$(aws ssm get-parameter --region us-west-2 --with-decryption --output text --query Parameter.Value --name gitlab-runners-dockerhub-token)

# Configure Docker
mkdir -p /root/.docker
echo "{
  \"auths\": {
    \"https://index.docker.io/v1/\": {
      \"auth\": \"$DOCKER_LOGIN\"
    }
  },
  \"experimental\": \"enabled\",
  \"features\": {
    \"buildkit\": \"true\"
  }
}" > /root/.docker/config.json
EOT
}
