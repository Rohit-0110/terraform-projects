locals {
  instance_name = "${var.purpose}-${var.department}-${random_id.instance_suffix.hex}"
}

resource "random_id" "instance_suffix" {
  byte_length = 3
}

resource "aws_instance" "webserver" {
  ami           = var.ami
  instance_type = var.instance_type
  tags = {
    Name = local.instance_name
  }
  user_data              = file("./install-nginx.sh")
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

resource "aws_eip" "static_ip" {
  instance = aws_instance.webserver.id
}
