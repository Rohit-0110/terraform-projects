resource "aws_security_group" "allow_ssh_http" {
  name_prefix = "allow_ssh_http"

  dynamic "ingress" {
    iterator = port
    for_each = var.ingress_ports
    content {
      from_port   = port.value
      to_port     = port.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2_instance" {
  ami           = "ami-06c68f701d8090592"
  instance_type = "t2.micro"
  key_name      = "my-terraform-key"

  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  associate_public_ip_address = true

  tags = {
    Name = "NginxServer"
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("/root/my-terraform-key.pem")
      host        = self.public_ip
    }

    inline = [
      "sudo yum update -y",
      "sudo yum install -y nginx",
      "sudo systemctl start nginx",
      "sudo systemctl enable nginx"
    ]
  }

}

output "instance_public_ip" {
  value = aws_instance.ec2_instance.public_ip
}