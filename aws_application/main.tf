variable "region" {
  type        = string
  default     = "us-east-1"
  description = "aws default region"
}

# ------------------ PROVIDER ------------------
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.7.0"
    }
  }
}

provider "aws" {
  region = var.region # Replace with your desired AWS region
}


# ------------------ VPC ------------------

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# ------------------ EC2 ------------------

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical owner ID for Ubuntu AMIs

  filter {
    name   = "name"
    values = ["ubuntu/images/*/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group - Allow SSH and HTTP
resource "aws_security_group" "allow_tls" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 9090
    to_port          = 9090
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "allow_tls"
  }
}

# EC2 Instance 1 - t2.small
resource "aws_instance" "app1" {
  ami           = data.aws_ami.ubuntu.id # Replace with your desired AMI ID
  instance_type = "t2.small"
  subnet_id     = data.aws_subnets.default.ids[0]

  security_groups = [aws_security_group.allow_tls.id]

  root_block_device {
    volume_size = 10
  }
  user_data = filebase64("${path.module}/userdata_1.sh")

  tags = {
    Name = "app1"
  }

}