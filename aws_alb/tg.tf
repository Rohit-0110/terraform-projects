# Target groups
# HTTPS
resource "aws_lb_target_group" "dev_tg" {
  name     = "tc-dev-fms"
  port     = 4544
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.psi_vpc.id

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

# alternative HTTPS
resource "aws_lb_target_group" "dev_alternative_tg" {
  name     = "tc-dev-gw"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.psi_vpc.id

  health_check {
    interval            = 30
    path                = "/ping"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

# HTTPS
resource "aws_lb_target_group" "prod_tg" {
  name     = "tc-prod-fms"
  port     = 4544
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.psi_vpc.id

  health_check {
    interval            = 30
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

# alternative HTTPS
resource "aws_lb_target_group" "prod_alternative_tg" {
  name     = "tc-prod-gw"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.psi_vpc.id

  health_check {
    interval            = 30
    path                = "/ping"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
  }
}

# Attaching Target groups
resource "aws_lb_target_group_attachment" "dev_tg_attach" {
  target_group_arn = aws_lb_target_group.dev_tg.arn
  target_id        = data.aws_instance.siemens_dev.id
  port             = 4544
}

resource "aws_lb_target_group_attachment" "dev_tg_alternative_attach" {
  target_group_arn = aws_lb_target_group.dev_alternative_tg.arn
  target_id        = data.aws_instance.siemens_dev.id
  port             = 3000
}

resource "aws_lb_target_group_attachment" "prod_tg_attach" {
  target_group_arn = aws_lb_target_group.prod_tg.arn
  target_id        = data.aws_instance.siemens_prod.id
  port             = 4544
}

resource "aws_lb_target_group_attachment" "prod_tg_alternative_attach" {
  target_group_arn = aws_lb_target_group.prod_alternative_tg.arn
  target_id        = data.aws_instance.siemens_prod.id
  port             = 3000
}