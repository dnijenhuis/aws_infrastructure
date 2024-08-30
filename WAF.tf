# In this file the Web Application Firewall (WAF) is created. For now, this is done in a very minimal
# manner for demonstration purposes. Only a very small IPv4 range is blocked: traffic from NordVPN's 
# Australian server with number 623. Depending on the requirements of the company, this list can be
# expanded to include IPv6, IP-ranges from certain regions, from VPN-providers, etc. These lists need to 
# be regularly updated. 
# CloudWatch metrics are turned off for now. If the company desires so, this can be turned on later. 
# However, there are costs involved in this.

# US: IPv4 IP Set for an Australian NordVPN server for demo purposes.
resource "aws_wafv2_ip_set" "us_australia_ip_set" {
  name               = "australia-ip-set-us"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = [
    "86.48.8.0/24",   # Australia server 623 
    "86.48.8.255/32", # Australia server 623 
    "86.48.8.254/32"  # Australia server 623 
  ]

  tags = {
    Name = "australia-ip-set-us"
  }

  provider = aws.us_east_1
}

# EU: IPv4 IP Set for an Australian NordVPN server for demo purposes.
resource "aws_wafv2_ip_set" "eu_australia_ip_set" {
  name               = "australia-ip-set-eu"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"

  addresses = [
    "86.48.8.0/24",   # Australia server 623 (CIDR notation for a range)
    "86.48.8.255/32", # Australia server 623 (Specific IP)
    "86.48.8.254/32"  # Australia server 623 (Specific IP - corrected format)
  ]

  tags = {
    Name = "australia-ip-set-eu"
  }

  provider = aws.eu_central_1
}

# Web ACL to Block Traffic from Australia in US Region.
resource "aws_wafv2_web_acl" "us_web_acl" {
  name        = "block-australia-us-web-acl"
  scope       = "REGIONAL"
  description = "Web ACL blocking AU-traffic in the US."

  default_action {
    allow {}
  }

  rule {
    name     = "block-australia-ipv4"
    priority = 1

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.us_australia_ip_set.arn
      }
    }

# CloudWatch metrics are turned off for now. If the company desires so, this can be turned on later. However, there
# are costs involved in this.
    visibility_config {
      cloudwatch_metrics_enabled = false 
      metric_name                = "blockAustraliaIpv4"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "usWebACL"
    sampled_requests_enabled   = false
  }

  provider = aws.us_east_1
}

# Web ACL to Block Traffic from Australia in EU Region.
resource "aws_wafv2_web_acl" "eu_web_acl" {
  name        = "block-australia-eu-web-acl"
  scope       = "REGIONAL"
  description = "Web ACL blocking AU-traffic in the EU."

  default_action {
    allow {}
  }

  rule {
    name     = "block-australia-ipv4"
    priority = 1

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.eu_australia_ip_set.arn
      }
    }

# CloudWatch metrics are turned off for now. If the company desires so, this can be turned on later. However, there
# are costs involved with this.
    visibility_config {
      cloudwatch_metrics_enabled = false
      metric_name                = "blockAustraliaIpv4"
      sampled_requests_enabled   = false
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = false
    metric_name                = "euWebACL"
    sampled_requests_enabled   = false
  }

  provider = aws.eu_central_1
}

# US: Association of the web ACL with its respective ALB.
resource "aws_wafv2_web_acl_association" "us_web_acl_association" {
  resource_arn = aws_lb.us_alb.arn
  web_acl_arn  = aws_wafv2_web_acl.us_web_acl.arn
  provider = aws.us_east_1
}

# EU: Association of the web ACL with its respective ALB.
resource "aws_wafv2_web_acl_association" "eu_web_acl_association" {
  resource_arn = aws_lb.eu_alb.arn
  web_acl_arn  = aws_wafv2_web_acl.eu_web_acl.arn
  provider = aws.eu_central_1
}
