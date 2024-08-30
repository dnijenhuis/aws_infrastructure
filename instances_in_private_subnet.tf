# In this file the Windows machines for the employees are created. Initially, for dev/test, I used a free
# tier instance. However, due to the free tier's very very low-end specifications, starting up this instance and working 'in' it,
# drove me quite crazy very fast. So I upgraded it to 'm5.large'. 
#
# The private IP address is not randomly assigned but specified. This is necessary so that the employees who will login to the machines, 
# have the same IP they need to enter when setting up a connection through RDP. 
# Note: in the end the company and employees will probably want to keep the instances they spun up 'alive' so that the data on them 
# does not get deleted every time the Terraform code / AWS infrastructure gets updated/re-applied. This could be achieved through implementing
# lifecycle code. However, this is beyond the scope of this project. 
# Furthermore, this code should be expanded for the additional employees and for additional settings (user_data script) on the instances.

# Windows machine for the employees with a specific IP.
resource "aws_instance" "us_windows_instance_private" {
  provider = aws.us_east_1
  ami           = "ami-07cc1bbe145f35b58"
  instance_type = "m5.large" # This resource has an estimated cost of $ 850 per year when the company keeps it running 24/7.
  key_name      = "my_key_us" # Created manually in AWS console.
  subnet_id     = aws_subnet.us_private_subnet_1b.id
  security_groups = [aws_security_group.us_private_sg.id]

  private_ip = "10.0.0.132"

  associate_public_ip_address = false

  # The script for the private instance does the following basic tasks:
  # - Update Windows;
  # - Enable Remote Desktop Protocol (RDP);
  # - Enable ICMP (Ping) Traffic (when there will be more machines in the privat subnet, this could
  #   be used when there are connection problems with one of the machines.)
  #
  # This could be put in a variable as well. However, I can image that every employee needs a different virtual machine
  # and different scripts on it. Therefor, it made more sense to me to keep all scripts (1 for now) in this file and not 
  # clutter the .tfvars file.
    user_data = <<-EOF
    <powershell>
    # Update Windows
    Install-WindowsUpdate -AcceptAll -IgnoreReboot

    # Enable RDP
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\' -Name 'fDenyTSConnections' -Value 0
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

    # Enable ICMP (Ping)
    New-NetFirewallRule -DisplayName "Allow ICMPv4-In" -Protocol ICMPv4 -Direction Inbound -Action Allow
    New-NetFirewallRule -DisplayName "Allow ICMPv4-Out" -Protocol ICMPv4 -Direction Outbound -Action Allow
    </powershell>
  EOF

  tags = {
    Name = "us-windows-remote_desktop-private-subnet"
  }
}
