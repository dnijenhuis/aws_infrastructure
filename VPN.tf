# This file contains the basic setup for the client-VPN. The method used is Mutual Authentication. 
# It gets associated with the US subnet and lets all authorized clients access.
# No direct access is allowed to EU VPC subnets via the VPN because I have VPC-peering for this. 
# This might not be ideal regarding latency but it increases security.

# Create a Client VPN endpoint in the US VPC using Mutual Authentication
resource "aws_ec2_client_vpn_endpoint" "us_vpn_endpoint" {
  provider           = aws.us_east_1  
  client_cidr_block  = "172.16.0.0/22" 

  # Mutual Authentication instead of IAM based. See my end product for phase 2 for a discussion of this.
  authentication_options {
    type                      = "certificate-authentication"
    root_certificate_chain_arn = var.client_certificate_arn_root  # ARN of the root certificate for the client certificate.
  }

  connection_log_options {
    enabled = false    
  }

  transport_protocol = "udp"
  server_certificate_arn = var.certificate_arn_us_east_1

  tags = {
    Name = "us-client-vpn-endpoint"
  }

# Lifecycle is for now set to false. This could eventually be set to 'true' so that the 
# same endpoint (and therefore certificates) keep existing. Everytime the endpoint gets
# destroyed due to destroying and applying Terraform, the VPN-client (i.e. OpenVPN) needs
# to be fed an updated .ovpn file. This is not desirable for the company.
  lifecycle {
  prevent_destroy = false  
}
}

# The VPN endpoint is (only) associated with the US private subnet (us-east-1b).
resource "aws_ec2_client_vpn_network_association" "us_vpn_association_private" {
  provider               = aws.us_east_1
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.us_vpn_endpoint.id
  subnet_id              = aws_subnet.us_private_subnet_1b.id
}


resource "aws_ec2_client_vpn_authorization_rule" "us_vpn_auth_rule" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.us_vpn_endpoint.id
  target_network_cidr    = "10.0.0.0/24"  # US VPC CIDR. EU VPC should also be accessable due to VPC Peering.
  authorize_all_groups   = true  # Authenticated clients are allowed. 

  description = "Authorize VPN clients to access VPC"
}





