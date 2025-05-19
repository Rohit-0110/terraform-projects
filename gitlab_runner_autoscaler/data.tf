data "aws_vpc" "vpc_oregon" {
  tags = {
    Name = ""
  }
}

data "aws_subnet" "private_main" {
  tags = {
    Name = "private_main"
  }
}

data "aws_subnet" "private_main_2b" {
  tags = {
    Name = "private_main-2b"
  }
}

data "aws_security_group" "full_vpc_access" {
  vpc_id = data.aws_vpc.vpc_oregon.id
  name   = "wide open inside VPC"
}
