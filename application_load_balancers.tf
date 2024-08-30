# This file contains the code for the Application Load Balancers (ALBs).
# In every region, an ALB and listeners are created. The ALBs are external (internet facing), and
# are associated with the public subnets of their region. They have their own
# security group. The listeners forward HTTPS traffic and redirect HTTP traffic to 
# HTTPS so that all traffic is HTTPS/encrypted. 

# US ALB.
resource "aws_lb" "us_alb" {
  provider = aws.us_east_1
  name     = "us-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.us_alb_sg.id]
  subnets = [
    aws_subnet.us_public_subnet_1a.id,
    aws_subnet.us_public_subnet_1b.id
  ]
  tags = {
    Name = "us-alb"
  }
}

# Listener for HTTP (port 80) with redirect to HTTPS.
resource "aws_lb_listener" "us_http_listener" {
  provider = aws.us_east_1
  load_balancer_arn = aws_lb.us_alb.arn
  port     = "80"
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol = "HTTPS"
      port     = "443"
      status_code = "HTTP_301" # This code indicates that the redirect is permanent. 
    }
  }
}

# Listener for HTTPS (port 443), forwarding to target group/web servers.
resource "aws_lb_listener" "us_https_listener" {
  provider = aws.us_east_1
  load_balancer_arn = aws_lb.us_alb.arn
  port     = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08" # Here the SSL protocol is defined. This is the standard one.
  certificate_arn = var.certificate_arn_us_east_1

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.us_https_target_group.arn
  }
}

# EU ALB.
resource "aws_lb" "eu_alb" {
  provider = aws.eu_central_1
  name     = "eu-alb"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.eu_alb_sg.id]
  subnets = [
    aws_subnet.eu_public_subnet_1a.id,
    aws_subnet.eu_public_subnet_1b.id
  ]
  enable_deletion_protection = false
  tags = {
    Name = "eu-alb"
  }
}

# Listener for HTTP (port 80) with redirect to HTTPS.
resource "aws_lb_listener" "eu_http_listener" {
  provider = aws.eu_central_1
  load_balancer_arn = aws_lb.eu_alb.arn
  port     = "80"
  protocol = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      protocol = "HTTPS"
      port     = "443"
      status_code = "HTTP_301"  # This code indicates that the redirect is permanent. 
    }
  }
}

# Listener for HTTPS (port 443), forwarding to target group/web servers.
resource "aws_lb_listener" "eu_https_listener" {
  provider = aws.eu_central_1
  load_balancer_arn = aws_lb.eu_alb.arn
  port     = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.certificate_arn_eu_central_1

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.eu_https_target_group.arn
  }
}
