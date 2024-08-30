# The code for the autoscaling groups (ASGs) is contained in this file. First, the target groups are 
# defined. These are the bridge between the ALBs and the instances. They determine how traffic from the 
# internet that reaches the ALBs is distributed to which (healthy) instances. Initially, also target groups for 
# HTTP were included. However, since HTTP traffic is redirected to HTTPS, these have been removed. 
# Furthermore, launch templates, the actual ASGs and scaling policies are created. 
#
# In summary, every region (US and EU) has 1 ASG. This ASG places a minimum of 1 web server in each of
# the regions' two AZs. In other words, there will always be a minimum of (2 regions * 2 AZs =) 4 web
# servers online world wide. The current settings include a maximum of 4 instances per region (so 2*2*2=8 world wide). 
# If the company requires, this can easily be adjusted in the future.  
# Also, in the future, the company could choose to make the health checks more strict. These are now quite
# 'loose', meaning that a server is quite quickly classified as healthy by the ALB. Though this is efficient 
# during development/testing, it increases the chance that website visitors are redirected to an unhealthy
# server, potentially causing them to go to another firm which does have a working website. 
#
# This file contains the (to my best knowledge) only remaining issue in my Terraform code. The instances 
# in the ASG still require a public IP for some reason to get the status healthy. I refer to my PPT (phase 2 
# end product) for a detailed discussion of this issue.

# Target Group for HTTPS (Port 443) in US. In the future the health checks could be made more strict if desirable. 
resource "aws_lb_target_group" "us_https_target_group" {
  provider = aws.us_east_1
  name     = "us-https-target-group"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.us_vpc.id

  health_check {
    path                = "/"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 3 # Increase to make more strict.
    unhealthy_threshold = 2 # Decrease to make more strict.
    matcher             = "200" # The type of health status code that is expected.
    protocol            = "HTTPS" # For HTTPS Target Group, protocol must be set to HTTPS for the health check
                                  # to prevent a '400' message, indicating that the server did not send a 200 response.
  }

  tags = {
    Name = "us-https-target-group"
  }
}

# Target Group for HTTPS (Port 443) in the EU. In the future the health checks could be made more strict if desirable. 
resource "aws_lb_target_group" "eu_https_target_group" {
  provider = aws.eu_central_1
  name     = "eu-https-target-group"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = aws_vpc.eu_vpc.id

  health_check {
    path                = "/"
    interval            = 15
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 2
    matcher             = "200"
    protocol            = "HTTPS" # For HTTPS Target Group, protocol must be set to HTTPS for the health check
                                  # to prevent a '400' message, indicating that the server did not send a 200 response.
  }

  tags = {
    Name = "eu-https-target-group"
  }
}

# Launch Template for US Region. It describes 'what' should be launched. 
resource "aws_launch_template" "us_launch_template" {
  name_prefix   = "us-launch-template-"
  image_id      = var.ami_ids["us-east-1"]
  instance_type = var.instance_type
  key_name      = var.key_names["us-east-1"]
  
  user_data     = base64encode(var.user_data_script)  # This contains some basic update code and a welcome message. 

  network_interfaces {
    security_groups = [aws_security_group.us_web_sg.id]
    associate_public_ip_address = true # Should ideally be turned to false in the future. 
  }

  lifecycle {
    create_before_destroy = false
  }
}

# Auto Scaling Group for US Region. It describes 'how many' instances, and 'where' they should be launched. 
resource "aws_autoscaling_group" "us_asg" {
  launch_template {
    id      = aws_launch_template.us_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier  = [aws_subnet.us_public_subnet_1a.id, aws_subnet.us_public_subnet_1b.id]
  desired_capacity     = 2
  min_size             = 2
  max_size             = 4
  health_check_type    = "EC2"
  health_check_grace_period = 300
  target_group_arns    = [
    aws_lb_target_group.us_https_target_group.arn
  ]

  tag {
    key                 = "Name"
    value               = "us-web-server"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = false
  }

  depends_on = [
    aws_launch_template.us_launch_template, 
    aws_lb.us_alb, 
    aws_lb_listener.us_https_listener,
    aws_subnet.us_public_subnet_1a,
    aws_subnet.us_public_subnet_1b
  ]
}

# The policies define scaling policies for the Auto Scaling Group in the US.
# For now, I used a 60% CPU use as a trigger. This ensures that the server will provide website
# visitors with a fast website.
resource "aws_autoscaling_policy" "us_target_tracking_policy" {
  name                   = "us-target-tracking-policy"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.us_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0  # 60% CPU use.
  }

  provider = aws.us_east_1
}


# Launch Template for EU Region. It describes 'what' should be launched. 
resource "aws_launch_template" "eu_launch_template" {
  name_prefix   = "eu-launch-template-"
  image_id      = var.ami_ids["eu-central-1"]
  instance_type = var.instance_type
  key_name      = var.key_names["eu-central-1"]
  user_data     = base64encode(var.user_data_script) # This contains some basic update code and a welcome message. 

  network_interfaces {
    security_groups = [aws_security_group.eu_web_sg.id]
    associate_public_ip_address = true # Should ideally be turned to false in the future. 
  }

  lifecycle {
    create_before_destroy = false
  }
  provider   = aws.eu_central_1  
}

# Auto Scaling Group for US Region. It describes 'how many' instances, and 'where' they should be launched.  
resource "aws_autoscaling_group" "eu_asg" {
  launch_template {
    id      = aws_launch_template.eu_launch_template.id
    version = "$Latest"
  }
  vpc_zone_identifier  = [aws_subnet.eu_public_subnet_1a.id, aws_subnet.eu_public_subnet_1b.id]
  desired_capacity     = 2
  min_size             = 2
  max_size             = 4
  health_check_type    = "EC2"
  health_check_grace_period = 300
  target_group_arns    = [
    aws_lb_target_group.eu_https_target_group.arn  # Reference to HTTPS target group only
  ]

  tag {
    key                 = "Name"
    value               = "eu-web-server"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = false
  }

  depends_on = [
    aws_launch_template.eu_launch_template,
    aws_lb.eu_alb,
    aws_lb_listener.eu_https_listener,
    aws_subnet.eu_public_subnet_1a,
    aws_subnet.eu_public_subnet_1b
  ]
  provider = aws.eu_central_1   # Ensures the ASG uses the correct region
}

# The policies define scaling policies for the Auto Scaling Group in the EU. 
# For now, I used a 60% CPU use as a trigger. This ensures that the server will provide website
# visitors with a fast website.
resource "aws_autoscaling_policy" "eu_target_tracking_policy" {
  name                   = "eu-target-tracking-policy"
  policy_type            = "TargetTrackingScaling"
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.eu_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 60.0  # 60% CPU use.
  }

  provider = aws.eu_central_1
}
