# This file contains the DNS information and makes sure the website redirects to the correct load balancer. 
# For latency purposes, the set-up is as follows:
# - South- and North-Amercian visitors are redirected to the US-ALB (and therefore US web servers);
# - The rest of the world is redirected to the EU-ALB (and therefore EU web servers).

# Route53 Record for the US Region (North-America).
resource "aws_route53_record" "us_na" {
  zone_id = "Z0112442I22DNZJHUPQK" # Zone-ID created in and retrieved from AWS console.
  name    = "www.92125638.com"
  type    = "CNAME"
  ttl     = 300 # Time to live in sec. Every 300 sec the DNS resolver info is updated.
  records = [aws_lb.us_alb.dns_name]

  set_identifier = "us-na-geolocation"
  geolocation_routing_policy {
    continent = "NA"  # North-America
  }
}

# Route53 Record for the US Region (South-America).
resource "aws_route53_record" "us_sa" {
  zone_id = "Z0112442I22DNZJHUPQK"
  name    = "www.92125638.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.us_alb.dns_name]

  set_identifier = "us-sa-geolocation"
  geolocation_routing_policy {
    continent = "SA"  # South-America
  }
}

# Route53 Record for the EU Region.
resource "aws_route53_record" "eu" {
  zone_id = "Z0112442I22DNZJHUPQK"
  name    = "www.92125638.com"
  type    = "CNAME"
  ttl     = 300
  records = [aws_lb.eu_alb.dns_name]

  set_identifier = "eu-geolocation"
  geolocation_routing_policy {
    country = "*" # The rest of the world not included in N-A and S-A.
  }
}
