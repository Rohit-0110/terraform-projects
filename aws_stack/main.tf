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
      version = ">= 5.79.0"
    }
  }
}

provider "aws" {
  region = var.region # Replace with your desired AWS region
}


# ------------------ VPC ------------------

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "lab-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.region}a", "${var.region}b", "${var.region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway      = true
  single_nat_gateway      = true
  enable_vpn_gateway      = false
  map_public_ip_on_launch = true

  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

#--------------------IAM-------------------

# IAM Role for SSM Management
resource "aws_iam_role" "ssm_manage_role" {
  name = "ssm_managed_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name = "ssm_managed_role"
  }
}

# Attach AmazonSSMManagedInstanceCore Policy to the IAM Role
resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
  role       = aws_iam_role.ssm_manage_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# IAM Instance Profile for EC2 Instances
resource "aws_iam_instance_profile" "ssm_instance_profile" {
  name = "EC2_SSM_Instance_Profile"
  role = aws_iam_role.ssm_manage_role.name
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
  vpc_id      = module.vpc.vpc_id

  ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }


  ingress {
    description      = "TLS from VPC"
    from_port        = 8080
    to_port          = 8080
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
  subnet_id     = module.vpc.private_subnets[0]

  security_groups = [aws_security_group.allow_tls.id]

  root_block_device {
    volume_size = 10
  }

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  user_data = filebase64("${path.module}/userdata_1.sh")

  tags = {
    Name = "app1"
  }

}

# EC2 Instance 2 - t2.small
resource "aws_instance" "app2" {
  ami           = data.aws_ami.ubuntu.id # Replace with your desired AMI ID
  instance_type = "t2.small"
  subnet_id     = module.vpc.private_subnets[0]

  security_groups = [aws_security_group.allow_tls.id]
  root_block_device {
    volume_size = 10
  }

  iam_instance_profile = aws_iam_instance_profile.ssm_instance_profile.name

  user_data = filebase64("${path.module}/userdata_2.sh")

  tags = {
    Name = "app2"
  }
}