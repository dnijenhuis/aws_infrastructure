# This output file lets Terraform/the terminal present the private IP of the Windows machine(s) 
# for the employee(s). This information is necessary to set-up a Remote Desktop connection.

output "us_windows_instance_private_ip" {
  value = aws_instance.us_windows_instance_private.private_ip
  description = "Private IP of the Windows instance in the US private subnet"
}