# LoadBalancer For Prod
resource "aws_lb" "prod_plm_lb" {
  name               = "prod-plm-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids
  tags               = local.plm.tags
}

# Listener HTTP
resource "aws_lb_listener" "HTTP_prod" {
  load_balancer_arn = aws_lb.prod_plm_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

# Listerner HTTPS
resource "aws_lb_listener" "HTTPS_prod" {
  load_balancer_arn = aws_lb.prod_plm_lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.plm_cert.arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "{status:okay}"
      status_code  = "200"
    }
  }
}

# Listening Rules for HTTPS
# Weighted Forwarding Action
resource "aws_lb_listener_rule" "tc_prod_plm_routing" {
  listener_arn = aws_lb_listener.HTTPS_prod.arn
  priority     = 1

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.prod_alternative_tg.arn   
        weight = 100 #primary
      }

      target_group {
        arn    = aws_lb_target_group.prod_tg.arn
        weight = 100 #fallback
      }

      stickiness {
        enabled  = true
        duration = 600
      }
    }
  }

  condition {
    host_header {
      values = ["tc-prod.plm.test.com"]
    }
  }
}