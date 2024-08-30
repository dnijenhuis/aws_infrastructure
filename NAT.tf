# This file contains the code for the NAT and its elastic IP. This resoucerse is necessary for employees'
# Windows machines in the private subnet so they can access the internet. 

# Create an elastic IP.
resource "aws_eip" "us_nat_eip" {
  provider = aws.us_east_1
  domain   = "vpc"

  tags = {
    Name = "us-nat-eip"
  }
}

# Create the NAT Gateway in the public subnet through which the Windows machines will access the internet.
# A NAT Gateway has to be placed in a public subnet even though the Windows machines are in the private subnet.
resource "aws_nat_gateway" "us_nat_gateway" {
  provider       = aws.us_east_1
  allocation_id  = aws_eip.us_nat_eip.id
  subnet_id      = aws_subnet.us_public_subnet_1b.id  # The NAT Gateway is in US public subnet 1b.
  
  tags = {
    Name = "us-nat-gateway"
  }
}
