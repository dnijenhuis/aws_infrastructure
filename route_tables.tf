# In this Terraform file, the route tables are created and associated with the subnets.

# Route table for public subnets US.
resource "aws_route_table" "us_public_route_table" {
  provider = aws.us_east_1
  vpc_id   = aws_vpc.us_vpc.id

  route {
    cidr_block = "0.0.0.0/0" # All IPs.
    gateway_id = aws_internet_gateway.us_internet_gateway.id
  }

  tags = {
    Name = "us-public-route-table"
  }
}

# Association of the US public route table with public subnet 1a.
resource "aws_route_table_association" "us_public_route_table_association_1a" {
  provider      = aws.us_east_1
  subnet_id     = aws_subnet.us_public_subnet_1a.id
  route_table_id = aws_route_table.us_public_route_table.id
}

# Association of the US public route table with public subnet 1b.
resource "aws_route_table_association" "us_public_route_table_association_1b" {
  provider      = aws.us_east_1
  subnet_id     = aws_subnet.us_public_subnet_1b.id
  route_table_id = aws_route_table.us_public_route_table.id
}

# US route table for the private subnet.
resource "aws_route_table" "us_private_route_table" {
  provider = aws.us_east_1
  vpc_id   = aws_vpc.us_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.us_nat_gateway.id # The private route has to go through the NAT.
  }

  tags = {
    Name = "us-private-route-table"
  }
}

# Associaton of the US private route table with the private subnet.
resource "aws_route_table_association" "us_private_route_table_association_1b" {
  provider      = aws.us_east_1
  subnet_id     = aws_subnet.us_private_subnet_1b.id
  route_table_id = aws_route_table.us_private_route_table.id
}

# Route table for public subnets EU.
resource "aws_route_table" "eu_public_route_table" {
  provider = aws.eu_central_1
  vpc_id   = aws_vpc.eu_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eu_internet_gateway.id
  }

  tags = {
    Name = "eu-public-route-table"
  }
}

# Association of the EU public route table with public subnet 1a.
resource "aws_route_table_association" "eu_public_route_table_association_1a" {
  provider      = aws.eu_central_1
  subnet_id     = aws_subnet.eu_public_subnet_1a.id
  route_table_id = aws_route_table.eu_public_route_table.id
}

# Association of the EU public route table with public subnet 1B.
resource "aws_route_table_association" "eu_public_route_table_association_1b" {
  provider      = aws.eu_central_1
  subnet_id     = aws_subnet.eu_public_subnet_1b.id
  route_table_id = aws_route_table.eu_public_route_table.id
}

