# In this file, first the provider/regions are set. These are us-east-1 and eu-central-1. 
# The access and secret keys are also included in the form of variables. The reason that
# I chose variables, is so that the code can be safely uploaded to GitHub / the IU website
# without exposing credentials (as long as the terraform.tfvars file is not included ofcourse).
#
# Furthermore, a VPC is created for both the EU and the US. The US has 2 public subnets
# and 1 private subnet. The EU has 2 public subnets but not a private subnet. The public
# subnets contain the web servers and are spread out over 2 Availability Zones (AZs).  
# The private subnet contains windows machines where the company employees will work on.

# Provider for US.
provider "aws" {
  alias      = "us_east_1"
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# Provider for EU.
provider "aws" {
  alias      = "eu_central_1"
  region     = "eu-central-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# VPC in US.
resource "aws_vpc" "us_vpc" {
  provider   = aws.us_east_1
  cidr_block = "10.0.0.0/24" # As dicussed in my phase 1 end product / concept, a small network 
                             # is sufficient for this company.
  tags = {
    Name = "us-vpc"
  }
}

# VPC in EU.
resource "aws_vpc" "eu_vpc" {
  provider   = aws.eu_central_1
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "eu-vpc"
  }
}

# Public Subnet in us-east-1a.
resource "aws_subnet" "us_public_subnet_1a" {
  provider                = aws.us_east_1
  vpc_id                  = aws_vpc.us_vpc.id
  cidr_block              = "10.0.0.0/26"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = false  # Web servers do not directly face the internet, only through the ALB. So no public IP.
  tags = {
    Name = "us-public-subnet-1a"
  }
}

# Public Subnet in us-east-1b.
resource "aws_subnet" "us_public_subnet_1b" {
  provider                = aws.us_east_1
  vpc_id                  = aws_vpc.us_vpc.id
  cidr_block              = "10.0.0.64/26"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false  # Web servers do not directly face the internet, only through the ALB. So no public IP.
  tags = {
    Name = "us-public-subnet-1b"
  }
}

# Private Subnet in us-east-1b for Windows Machines for employees.
# Instances in the private subnet are reached through VPN, and access the internet 
# themselves through a NAT in the public subnet of the same AZ. So they do not get a public IP.
resource "aws_subnet" "us_private_subnet_1b" {
  provider                = aws.us_east_1
  vpc_id                  = aws_vpc.us_vpc.id
  cidr_block              = "10.0.0.128/26"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = false    
  tags = {
    Name = "us-private-subnet-1b"
  }
}

# Public Subnet in eu-central-1a.
resource "aws_subnet" "eu_public_subnet_1a" {
  provider                = aws.eu_central_1
  vpc_id                  = aws_vpc.eu_vpc.id
  cidr_block              = "10.0.1.0/26"
  availability_zone       = "eu-central-1a"
  map_public_ip_on_launch = false  # Web servers do not directly face the internet, only through the ALB. So no public IP.
  tags = {
    Name = "eu-public-subnet-1a"
  }
}

# Public Subnet in eu-central-1b.
resource "aws_subnet" "eu_public_subnet_1b" {
  provider                = aws.eu_central_1
  vpc_id                  = aws_vpc.eu_vpc.id
  cidr_block              = "10.0.1.64/26"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = false  # Web servers do not directly face the internet, only through the ALB. So no public IP.
  tags = {
    Name = "eu-public-subnet-1b"
  }
}
