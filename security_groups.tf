# In this file, the security groups are created. These include security groups for the ALBs, 
# for the private subnet and public subnet instances, for the NAT, and for the VPN Gateway.

# Security Group for the Application Load Balancer in the US. It should accept inbound
# HTTP and HTTPS traffic, and allow all outbound traffic so the web servers can send 
# traffic to website visitors.
resource "aws_security_group" "us_alb_sg" {
  provider = aws.us_east_1
  vpc_id   = aws_vpc.us_vpc.id

  # Allow all HTTP traffic from anywhere.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all HTTPS traffic from anywhere.
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "us-alb-security-group"
  }
}


# Security Group for the Application Load Balancer in the EU. It should accept inbound
# HTTP and HTTPS traffic, and allow all outbound traffic so the web servers can send 
# traffic to website visitors.
resource "aws_security_group" "eu_alb_sg" {
  provider = aws.eu_central_1
  vpc_id   = aws_vpc.eu_vpc.id

  # Allow all HTTP traffic from anywhere.
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  # Allow all HTTPS traffic from anywhere.
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eu-alb-security-group"
  }
}

# Security Group for Web Servers in the US. It allows HTTP and HTTPS traffic with the ALB. 
# Servers can be SSH'd and pinged from within the internal network. Outbound traffic
# is completely set open in order to send traffic to website visitors.
resource "aws_security_group" "us_web_sg" {
  provider = aws.us_east_1
  vpc_id   = aws_vpc.us_vpc.id

  # Allow HTTP traffic only from the ALB.
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.us_alb_sg.id]
  }

  # Allow HTTPS traffic only from the ALB.
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.us_alb_sg.id]
  }

  # Allow SSH traffic from within the US VPC.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  # Allow SSH traffic from EC2 Instance Connect service necessary for connection through AWS console. 
  # I used this to login to the instances through the AWS console in order to test whether the ASG
  # upscaling was working.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["18.206.107.24/29"] # I retrieved this from https://ip-ranges.amazonaws.com/ip-ranges.json
                                       # look for us-east-1 / EC2_INSTANCE_CONNECT
  }

  # Allow SSH traffic from EU VPC.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  # Allow ICMP (ping) traffic from within the US VPC.
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/24"] 
  }

  # Allow ICMP (ping) traffic from EU VPC.
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "us-web-security-group"
  }
}

# Security Group for Web Servers in the EU. It allows HTTP and HTTPS traffic with the ALB. 
# Servers can be SSH'd and pinged from within the internal network. Outbound traffic
# is completely set open in order to send traffic to website visitors.
resource "aws_security_group" "eu_web_sg" {
  provider = aws.eu_central_1
  vpc_id   = aws_vpc.eu_vpc.id

  # Allow HTTP traffic only from the ALB.
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.eu_alb_sg.id]
  }

  # Allow HTTPS traffic only from the ALB.
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.eu_alb_sg.id]
  }

  # Allow SSH traffic from within the EU VPC.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"] 
  }

  # Allow SSH traffic from US VPC.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"]
  }

  # Allow ICMP (ping) traffic from within the EU VPC.
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.1.0/24"]
  }

  # Allow ICMP (ping) traffic from US VPC.
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["10.0.0.0/24"]  
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eu-web-security-group"
  }
}

# Security Group for Private Subnet Instances in the US. In this subnet, the employees'
# Windows machines are placed. Therefore, they should be able to be accessed through 
# Remote Desktop software. Furthermore, all outbound traffic (through NAT) should be
# allowed.
resource "aws_security_group" "us_private_sg" {
  provider = aws.us_east_1
  vpc_id   = aws_vpc.us_vpc.id

  # Allow RDP traffic from anywhere.
  ingress {
    from_port   = 3389  # Port for using remote desktop software.
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "us-private-security-group"
  }
}
# Security group for the US NAT. It allows all outbound traffic and related inbound traffic. 
# So related inbound traffic and VPN-inbound traffic are the only inbound internet
# traffic that can reach the private instances.
resource "aws_security_group" "nat_sg" {
  provider = aws.us_east_1 
  vpc_id   = aws_vpc.us_vpc.id

  # Allow all outbound traffic to the internet so the employees can download software, browse, etc.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow return traffic for any established connections, so requested traffic can actually get back in.
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nat-security-group"
  }
}

# Security Group for the US VPN Gateway. The company could make the choice to limit the allowed inbound 
# traffic to US IPs since the employees are located there. However, for malevolent parties, this is easy to 
# circumvent by using a VPN service. Much better would be to specify the IPs of the 
# employee devices. Taking into account the scope of this project, this is not (yet) included in the code.
resource "aws_security_group" "vpn_sg" {
  provider = aws.us_east_1
  vpc_id   = aws_vpc.us_vpc.id

  # Allow all inbound traffic from anywhere.
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # For now, completely open, but should be limited in the future.
  }

  # Allow all outbound traffic to anywhere.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # For now, completely open, but should be limited in the future.
  }

  tags = {
    Name = "vpn-security-group"
  }
}
