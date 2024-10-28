resource "aws_instance" "webserver" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    name = "webserver"
  }
  user_data = <<-EOF
                #!/bin/bash
                sudo apt update
                sudo apt install apache2
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