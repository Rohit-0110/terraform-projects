resource "aws_instance" "webserver" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    name = "webserver"
  }
  # user_data = filebase64("/home/rohit/oneDrive/workSpace/Shell Script/k8s_tool.sh")
  user_data = <<-EOF
                #!/bin/bash
                # Install Dependencies
                sudo apt update
                sudo apt install apt-transport-https ca-certificates curl unzip gnupg wget bash-completion -y

                # Install aws cli
                curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
                unzip awscliv2.zip
                sudo ./aws/install

                # Install kubectl command
                curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.33/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
                sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
                echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.33/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
                sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list 
                sudo apt-get update
                sudo apt-get install -y kubectl

                kubectl version --client=true


                # Adding bash-completion
                kubectl completion bash | sudo tee /etc/bash_completion.d/kubectl > /dev/null
                sudo chmod a+r /etc/bash_completion.d/kubectl

                echo 'alias k=kubectl' >>~/.bashrc
                echo 'complete -o default -F __start_kubectl k' >>~/.bashrc

                source ~/.bashrc
                EOF

  key_name               = aws_key_pair.web.id
  vpc_security_group_ids = [aws_security_group.ssh_access.id]

}

resource "aws_key_pair" "web" {
  public_key = file("/home/rohit/.ssh/id_rsa.pub")

}

resource "aws_security_group" "ssh_access" {
  name        = "ssh-access"
  description = "allow ssh access"
  ingress {

    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

output "public_ip" {
  value = aws_instance.webserver.public_ip

}