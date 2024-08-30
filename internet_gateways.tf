# This file contains the Internet Gateway code. The Internet Gateways are used by the
# web servers (through the ALBs) and by the US NAT to access the internet.

# US Internet Gateway.
resource "aws_internet_gateway" "us_internet_gateway" {
  provider = aws.us_east_1
  vpc_id   = aws_vpc.us_vpc.id

  tags = {
    Name = "us-internet-gateway"
  }
}

# EU Internet Gateway.
resource "aws_internet_gateway" "eu_internet_gateway" {
  provider = aws.eu_central_1
  vpc_id   = aws_vpc.eu_vpc.id

  tags = {
    Name = "eu-internet-gateway"
  }
}


