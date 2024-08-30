# In this file, the VPC Peering connection is created. It connects the US VPC to the EU VPC, and implements this
# also in the route tables for the public and private subnets. Because of this, there is 1 big network and traffic 
# between the EU and VPC is internal traffic. This increases the security and accessibility, and makes it unnecessary 
# not needed to create a second VPN-endpoint for the EU-VPC.  

# Create VPC Peering Connection from us-east-1 to eu-central-1
resource "aws_vpc_peering_connection" "us_to_eu_peering" {
  provider = aws.us_east_1
  vpc_id   = aws_vpc.us_vpc.id
  peer_vpc_id = aws_vpc.eu_vpc.id
  peer_region = "eu-central-1"
  auto_accept = false # True is not possible in AWS, because the VPCs are in 2 different regions. 
                      #See 'accepter' code below.

  tags = {
    Name = "us-to-eu-peering"
  }
}

# The following two resources make routes per VPC.

# Main route table: Route in US VPC to route traffic to EU VPC.
resource "aws_route" "us_to_eu_route" {
  provider               = aws.us_east_1
  route_table_id         = aws_vpc.us_vpc.main_route_table_id
  destination_cidr_block = aws_vpc.eu_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.us_to_eu_peering.id
  depends_on = [aws_vpc_peering_connection.us_to_eu_peering]
}

# Main route table: Route in EU VPC to route traffic to US VPC.
resource "aws_route" "eu_to_us_route" {
  provider               = aws.eu_central_1
  route_table_id         = aws_vpc.eu_vpc.main_route_table_id
  destination_cidr_block = aws_vpc.us_vpc.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.us_to_eu_peering.id
  depends_on = [aws_vpc_peering_connection.us_to_eu_peering]
}

# The following three resources make routes per route table. 

# VPC peering route public route table US. 
resource "aws_route" "us_public_to_eu_vpc_route" {
  provider                   = aws.us_east_1
  route_table_id             = aws_route_table.us_public_route_table.id
  destination_cidr_block     = aws_vpc.eu_vpc.cidr_block
  vpc_peering_connection_id  = aws_vpc_peering_connection.us_to_eu_peering.id
}

# VPC peering route private (!) route table US. 
resource "aws_route" "us_private_to_eu_vpc_route" {
  provider                   = aws.us_east_1
  route_table_id             = aws_route_table.us_private_route_table.id
  destination_cidr_block     = aws_vpc.eu_vpc.cidr_block
  vpc_peering_connection_id  = aws_vpc_peering_connection.us_to_eu_peering.id
}

# VPC peering route public route table EU. 
resource "aws_route" "eu_public_to_us_vpc_route" {
  provider                   = aws.eu_central_1
  route_table_id             = aws_route_table.eu_public_route_table.id
  destination_cidr_block     = aws_vpc.us_vpc.cidr_block
  vpc_peering_connection_id  = aws_vpc_peering_connection.us_to_eu_peering.id
  depends_on                 = [aws_route_table.eu_public_route_table]
}



# This code below replaces the 'auto_accept' attribute mentioned above in the
# aws_vpc_peering_connection resource. This resource/code can also be used to connect 2 VPCs from 
# 2 different accounts but in this case it is used to connect 2 VPCs in 1 account but from
# 2 different regions.
resource "aws_vpc_peering_connection_accepter" "eu_accept_us_peering" {
  provider                  = aws.eu_central_1
  vpc_peering_connection_id = aws_vpc_peering_connection.us_to_eu_peering.id
  auto_accept               = true

  tags = {
    Name = "eu-accept-us-peering"
  }
}
