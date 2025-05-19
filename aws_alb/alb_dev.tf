# LoadBalancers For dev
resource "aws_lb" "dev_plm_lb" {
  name               = "dev-plm-lb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = var.security_group_ids
  subnets            = var.subnet_ids
  tags               = local.plm.tags
}

# Listener HTTP
resource "aws_lb_listener" "HTTP_dev" {
  load_balancer_arn = aws_lb.dev_plm_lb.arn
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

# Listener HTTPS
resource "aws_lb_listener" "HTTPS_dev" {
  load_balancer_arn = aws_lb.dev_plm_lb.arn
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
resource "aws_lb_listener_rule" "tc_dev_plm_routing" {
  listener_arn = aws_lb_listener.HTTPS_dev.arn
  priority     = 1

  action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.dev_alternative_tg.arn   
        weight = 100 #primary
      }

      target_group {
        arn    = aws_lb_target_group.dev_tg.arn
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
      values = ["tc-dev.plm.test.com"]
    }
  }
}